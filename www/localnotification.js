
    /*
     underscore impl of each and extend
     */
    var breaker = {};
    var ArrayProto = Array.prototype;

    var push = ArrayProto.push,
        slice = ArrayProto.slice,
        concat = ArrayProto.concat;

    var nativeForEach = ArrayProto.forEach;

    var each = function(obj, iterator, context) {
        if (obj == null) return;
        if (nativeForEach && obj.forEach === nativeForEach) {
            obj.forEach(iterator, context);
        } else if (obj.length === +obj.length) {
            for (var i = 0, l = obj.length; i < l; i++) {
                if (iterator.call(context, obj[i], i, obj) === breaker) return;
            }
        } else {
            for (var key in obj) {
                if (_.has(obj, key)) {
                    if (iterator.call(context, obj[key], key, obj) === breaker) return;
                }
            }
        }
    };

    var extend = function(obj) {
        each(slice.call(arguments, 1), function(source) {
            if (source) {
                for (var prop in source) {
                    obj[prop] = source[prop];
                }
            }
        });
        return obj;
    };

    /*
     end of underscore ext
     */

    var exec = require('cordova/exec');

    var LocalNotification = function () {};
               
    LocalNotification.Recurring = {
        None: '',
        Daily: 'daily',
        Weekly: 'weekly',
        Monthly: 'monthly',
        Yearly: 'yearly'
    };

    LocalNotification.prototype.add = function(options) {

        var defaults = {
            date: '',
            repeat: '',
            message: '',
	title:'',			
            hasAction: true,
            action: 'View',
            badge: 0,
            id: 0,
            sound:'',
            onNotification:null,
            userData: null
        };


        extend(defaults, options);

        if (typeof defaults.date == 'object') {
            defaults.date = Math.round(defaults.date.getTime()/1000);
        }
        exec(null,null,"LocalNotification","addNotification",[defaults]);
    };

    LocalNotification.prototype.cancel = function(id) {
        exec(null,null,"LocalNotification","cancelNotification",[id]);
    };
               
    LocalNotification.prototype.pulsePendingNotification = function() {
        exec(null,null,"LocalNotification","pulsePendingNotification",[]);
    };

    LocalNotification.prototype.cancelAll = function(id) {
        exec(null,null,"LocalNotification","cancelAllNotifications",[id]);
    };

    var notification = new LocalNotification();

    module.exports = notification;
