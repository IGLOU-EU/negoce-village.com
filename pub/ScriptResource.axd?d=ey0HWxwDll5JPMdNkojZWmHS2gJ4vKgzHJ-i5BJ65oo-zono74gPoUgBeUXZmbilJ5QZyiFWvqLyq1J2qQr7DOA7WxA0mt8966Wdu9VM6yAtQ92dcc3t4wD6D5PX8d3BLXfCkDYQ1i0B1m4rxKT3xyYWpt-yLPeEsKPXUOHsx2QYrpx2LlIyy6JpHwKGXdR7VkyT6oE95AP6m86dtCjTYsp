
Type.registerNamespace("Sparqube");
Sparqube.PostBackManager = function () {

    this._asyncPostbackTriggers = {};
    this._updatePanelIDs = {};

    this._postbackData = null;
    this._ajaxPostbackProcess = false;

    var mgr = Sys.WebForms.PageRequestManager.getInstance();
    mgr.add_initializeRequest(Function.createDelegate(this, this.initializeAjaxRequest));
}

Sparqube.PostBackManager.prototype =
{
    dispose: function () {
    },

    get_asyncPostbackTriggers: function () {
        return this._asyncPostbackTriggers;
    },
    set_asyncPostbackTriggers: function (arr) {
        if (null != arr) {
            for (var i = 0; i < arr.length; ++i) {
                this._asyncPostbackTriggers[arr[i]] = new Object();
            }
        }
    },

    get_updatePanelIDs: function () {
        return this._updatePanelIDs;
    },
    set_updatePanelIDs: function (arr) {
        if (null != arr) {
            for (var i = 0; i < arr.length; ++i) {
                this._updatePanelIDs[arr[i]] = new Object();
            }
        }
    },

    isAsyncPostbackTrigger: function (trigger, eventTriggerName) {
        var res = false;
        if (null != trigger) {
            if (eventTriggerName && (null != this._asyncPostbackTriggers[eventTriggerName])) {
                res = true;
            }
            else {
                res = this.isInsideUpdatePanel(trigger);
            }
        }        
        return res;
    },

    isInsideUpdatePanel: function (el) {
        var res = false;
        var elID = el.id;
        if (el.id && (null != this._updatePanelIDs[elID])) {
            res = true;
        }
        else {
            if ((el.tagName != "BODY") && (el.tagName != "HTML")) {
                res = this.isInsideUpdatePanel(el.parentNode);
            }
        }
        return res;
    },

    initializeAjaxRequest: function () {
        var args = arguments[1];

        if (!this._ajaxPostbackProcess) {
            var trigger = args.get_postBackElement();
            if (null != trigger) {

                var form = this.getParentByTagName(trigger, "FORM");
                if (null == form) {
                    form = document.forms[0];
                }

                var eventTrigger = (null != form.__EVENTTARGET) ? form.__EVENTTARGET.value : "";
                if (!eventTrigger) {
                    eventTrigger = trigger.getAttribute("name");
                }

                if (this.isAsyncPostbackTrigger(trigger, eventTrigger)) {
                    args.set_cancel(true);                    

                    var eventArg = (null != form.__EVENTARGUMENT) ? form.__EVENTARGUMENT.value : "";
                    this._postbackData = { EventTarget: eventTrigger, EventArgument: eventArg };

                    SP.SOD.executeFunc('SP.js', 'SP.ClientContext', Function.createDelegate(this, this.fakeCallback_Send));                    
                }
            }
        }
    },

    fakeCallback_Send: function () {
        var ctx = SP.ClientContext.get_current();        
        ctx.executeQueryAsync(Function.createDelegate(this, this.fakeCallback_End), Function.createDelegate(this, this.fakeCallback_End));
    },
    fakeCallback_End: function () {
        this._ajaxPostbackProcess = true;
        __doPostBack(this._postbackData.EventTarget, this._postbackData.EventArgument);
        this._ajaxPostbackProcess = false;
    },

    getParentByTagName: function (el, tagName) {
        var result = null;
        if (el && el.tagName) {
            if (el.tagName == tagName) {
                result = el;
            }
            else if ((el.tagName != "BODY") && (el.tagName != "HTML")) {
                result = this.getParentByTagName(el.parentNode, tagName)
            }
        }
        return result;
    }
}
Sparqube.PostBackManager.registerClass('Sparqube.PostBackManager', null, Sys.IDisposable);