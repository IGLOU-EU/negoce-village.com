
function DocumentColumn_AddMenuItem(menu, cmd, fieldData, idx)
{
    if ("" == cmd)
    {
        CAMSep(menu);
    }
    else
    {
        var menuItemData = fieldData.MenuItems[cmd];
        if (null != menuItemData)
        {
            var script = menuItemData.Script;
            if (script)
            {
                script = script.replace(/#INDEX#/gi, idx);
                var menuItemImgUrl = menuItemData.ImageUrl;
                if (cmd == "EditDocument")
                {
                    var docLink = fieldData.DocValue[idx];
                    if (docLink && docLink.IconUrl)
                    {
                        menuItemImgUrl = docLink.IconUrl;
                    }
                }
                CAMOpt(menu, menuItemData.Text, script, menuItemImgUrl, null, 100);
            }
        }
    }
}

function DocumentColumn_OpenPopup(el, event, fieldName, idx, arrCommands)
{
    var fieldData = window.DocumentColumn_Data[fieldName];
    var id = fieldData.TriggerID;

    if (window["edit-" + id])
    {
        return;
    }

    if ((null == arrCommands) || (0 == arrCommands.length))
    {
        return;
    }

    var menu = CMenu(id + "popup");
    menu.className = "ms-SrvMenuUI";

    for (var i = 0; i < arrCommands.length; ++i)
    {
        DocumentColumn_AddMenuItem(menu, arrCommands[i], fieldData, idx);
    }

    OMenu(menu, el.parentNode, null, null, -1);

    if (event && event.stopPropagation)
    {
        event.stopPropagation();
    }
}

function DocumentColumn_RowMouseOver(el, id, bHover)
{
    if (id && window["edit-" + id])
    {
        return;
    }
    DocumentColumn_AddClass(el, "s4-itm-hover", bHover);
    var elOpenPopup = DocumentColumn_GetChildEl(el, function (elem)
    {
        return elem.tagName && elem.className && (-1 != elem.className.indexOf("sq-doc-openpopup"));
    });
    if (null != elOpenPopup)
    {
        DocumentColumn_AddClass(elOpenPopup, "s4-ctx-show", bHover);
    }
}
function DocumentColumn_GetChildEl(el, fn)
{
    var result = null;
    if (el.tagName)
    {
        if (fn(el))
        {
            result = el;
        }
        else
        {
            for (var i = 0; i < el.childNodes.length; ++i)
            {
                var child = el.childNodes[i];
                result = DocumentColumn_GetChildEl(child, fn);
                if (null != result)
                {
                    break;
                }
            }
        }
    }
    return result;
}
function DocumentColumn_AddClass( el, cssClass, bAdd )
{
    if( bAdd )
    {
        var className = el.className;
        if (null == className) {
            el.className = cssClass;
        }
        else if (-1 == className.indexOf(cssClass)) {
            el.className = className + " " + cssClass;
        } 
    }
    else
    {
        if( null != el.className )
        {
            el.className=el.className.replace(cssClass, "");             
        }
    }
}
function DocumentColumn_EditLinkFromMenu(fieldName, idx)
{
    var fieldData = window.DocumentColumn_Data[fieldName];
    var div = document.getElementById(fieldData.ClientID);
    var table = DocumentColumn_GetChildEl(div, function (elem)
    {
        return elem.tagName == "TABLE";
    });
    var tr = table.rows[idx];
    DocumentColumn_EditLink(tr, fieldName, idx);
}

function DocumentColumn_ExecFileCommand(fieldName, idx, cmd)
{
    function fnCallback(dialogResult, returnValue)
    {
        if (dialogResult == SP.UI.DialogResult.OK)
        {
            var triggerId = window.DocumentColumn_Data[fieldName].TriggerID;

            var arg = "filecommand|" + cmd + "|" + idx + "|" + (((null != returnValue) && returnValue.newFileUrl) ? returnValue.newFileUrl : "");
            __doPostBack(triggerId, arg);
        }
    }
    switch (cmd)
    {
        case "EditDocument":
            {
                var data = window.DocumentColumn_Data[fieldName];
                var docLink = data.DocValue[idx];
                if (window.editDocumentWithProgID2)
                {
                    editDocumentWithProgID2(docLink.Url, '', 'SharePoint.OpenDocuments', (docLink.ForceCheckout ? '1' : '0'), docLink.WebUrl, (docLink.IsCheckedoutToLocal ? '1' : '0'));
                }
                break;
            }
        case "DeleteFile":
        case "CheckOut":
        case "DiscardCheckOut":
        case "CheckOutAndEditFile":
            {
                var msg = "";
                switch (cmd)
                {
                    case "DeleteFile":
                        {
                            msg = window.DocumentColumn_Data[fieldName].FileDeleteConfirm;
                            break;
                        }
                    case "DiscardCheckOut":
                        {
                            msg = window.DocumentColumn_Data[fieldName].FileDiscardCheckOutConfirm;
                            break;
                        }
                    case "CheckOutAndEditFile":
                        {
                            msg = window.DocumentColumn_Data[fieldName].FileCheckOutBeforeEditConfirm;
                            break;
                        }
                }

                if (!msg || confirm(msg))
                {
                    var triggerId = window.DocumentColumn_Data[fieldName].TriggerID;
                    var arg = "filecommand|" + cmd + "|" + idx;
                    __doPostBack(triggerId, arg);
                }
                break;
            }
        default:
            {
                var data = window.DocumentColumn_Data[fieldName];

                var docLink = data.DocValue[idx];
                var urlDialog = data.FileCmdDialogURL;

                var ch = urlDialog.indexOf('?') >= 0 ? '&' : '?';
                urlDialog += ch + "FileUrl=" + SP.Utilities.HttpUtility.urlKeyValueEncode(docLink.Url);
                if (docLink.NodeValue)
                {
                    urlDialog += "&NodeValue=" + SP.Utilities.HttpUtility.urlKeyValueEncode(docLink.NodeValue);
                }
                urlDialog += "&FileCommand=" + SP.Utilities.HttpUtility.urlKeyValueEncode(cmd);

                if ((cmd == "OpenFileLocation") || (cmd == "DownloadFile"))
                {
                    window.open(urlDialog, "_blank");
                }
                else
                {
                    urlDialog += "&IsDlg=1";
                    var options = {
                        url: urlDialog,
                        dialogReturnValueCallback: function (dialogResult, returnValue)
                        {
                            if (dialogResult == SP.UI.DialogResult.OK)
                            {
                                var triggerId = window.DocumentColumn_Data[fieldName].TriggerID;
                                var arg = "filecommand|" + cmd + "|" + idx + "|" + (((null != returnValue) && returnValue.newFileUrl) ? returnValue.newFileUrl : "");
                                __doPostBack(triggerId, arg);
                            }
                        }
                    };

                    var wnd = SP.UI.ModalDialog.showModalDialog(options);
                }
                break;
            }
    }
}