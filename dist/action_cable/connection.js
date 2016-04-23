var Connection,ConnectionMonitor,message_types,bind=function(t,e){return function(){return t.apply(e,arguments)}},slice=[].slice,indexOf=[].indexOf||function(t){for(var e=0,n=this.length;n>e;e++)if(e in this&&this[e]===t)return e;return-1};message_types=require("./internal").message_types,ConnectionMonitor=require("./connection_monitor"),Connection=function(){function t(t){this.consumer=t,this.open=bind(this.open,this),this.subscriptions=this.consumer.subscriptions,this.monitor=new ConnectionMonitor(this),this.disconnected=!0}return t.reopenDelay=500,t.prototype.send=function(t){return this.isOpen()?(this.webSocket.send(JSON.stringify(t)),!0):!1},t.prototype.open=function(){if(this.isActive())throw new Error("Existing connection must be closed before opening");return null!=this.webSocket&&this.uninstallEventHandlers(),this.webSocket=new WebSocket(this.consumer.url),this.installEventHandlers(),this.monitor.start(),!0},t.prototype.close=function(t){var e,n;return e=(null!=t?t:{allowReconnect:!0}).allowReconnect,e||this.monitor.stop(),this.isActive()&&null!=(n=this.webSocket)?n.close():void 0},t.prototype.reopen=function(){if(!this.isActive())return this.open();try{return this.close()}finally{setTimeout(this.open,this.constructor.reopenDelay)}},t.prototype.getProtocol=function(){var t;return null!=(t=this.webSocket)?t.protocol:void 0},t.prototype.isOpen=function(){return this.isState("open")},t.prototype.isActive=function(){return this.isState("open","connecting")},t.prototype.isState=function(){var t,e;return e=1<=arguments.length?slice.call(arguments,0):[],t=this.getState(),indexOf.call(e,t)>=0},t.prototype.getState=function(){var t,e,n;for(e in WebSocket)if(n=WebSocket[e],n===(null!=(t=this.webSocket)?t.readyState:void 0))return e.toLowerCase();return null},t.prototype.installEventHandlers=function(){var t,e;for(t in this.events)e=this.events[t].bind(this),this.webSocket["on"+t]=e},t.prototype.uninstallEventHandlers=function(){var t;for(t in this.events)this.webSocket["on"+t]=function(){}},t.prototype.events={message:function(t){var e,n,i,o;switch(i=JSON.parse(t.data),e=i.identifier,n=i.message,o=i.type,o){case message_types.welcome:return this.monitor.recordConnect(),this.subscriptions.reload();case message_types.ping:return this.monitor.recordPing();case message_types.confirmation:return this.subscriptions.notify(e,"connected");case message_types.rejection:return this.subscriptions.reject(e);default:return this.subscriptions.notify(e,"received",n)}},open:function(){return this.disconnected=!1},close:function(t){return this.disconnected?void 0:(this.disconnected=!0,this.monitor.recordDisconnect(),this.subscriptions.notifyAll("disconnected",{willAttemptReconnect:this.monitor.isRunning()}))},error:function(){}},t}(),module.exports=Connection;