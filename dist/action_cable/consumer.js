var Connection,ConnectionMonitor,Consumer,Subscription,Subscriptions;Connection=require("./connection"),ConnectionMonitor=require("./connection_monitor"),Subscriptions=require("./subscriptions"),Subscription=require("./subscription"),Consumer=function(){function n(n){this.url=n,this.subscriptions=new Subscriptions(this),this.connection=new Connection(this)}return n.prototype.send=function(n){return this.connection.send(n)},n.prototype.connect=function(){return this.connection.open()},n.prototype.disconnect=function(){return this.connection.close({allowReconnect:!1})},n.prototype.ensureActiveConnection=function(){return this.connection.isActive()?void 0:this.connection.open()},n}(),module.exports=Consumer;