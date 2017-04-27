const blank = {
    "time_of_day": {
        "before": 93600.0, // seconds since beginning of day, 21600 = 06:00:00, 93600 = 02:00:00 of next day
        "after": 21600.0 // these ranges constrained to 6am-2am currently, no one needs beyond
    },
    "location": {
        "region_name": "narnia", // dummy value
        "enter_exit": 1, // 1: enter, -1: exit
        "delay": 0, // 0: immediate, N>0: N minutes after
    },
    "plug": {
        "plug_unplug": 0, // 0: ignore, 1: plug in, -1: unplug
        "delay": 0, // 0: immediate, N>0: N minutes after
    },
    "prev_interactions": {
        "thrown": {
            "thresh_since_last": 40, // minimum #minutes between consecutive untouched notifications, default 40
            "last": 0 // seconds since 1970 of last interaction
        },
        "accepted": {
            "thresh_since_last": 720, // hold off for 12 hours after accepting
            "last": 0 // seconds since 1970 of last interaction
        },
        "declined": {
            "thresh_since_last": 120, // hold off two hours after decline
            "last": 0 // seconds since 1970 of last interaction
        }
    }
};