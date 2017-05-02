module.exports = {
    /**
     * Goals and associated microbehaviors, by user
     * 
     * Schema: [<username>: [<goaltitle>: [<microbehavior>: context]+]+]+
     */
    "delta":
    {
        "DTR harder": {
            "Plan my sprint": {
                "time_of_day": {
                    "before": 93600,
                    "after": 21600
                },
                "location": {
                    "region_name": "zelda",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 0.1,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 0.1, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 0.1, // hold off till next day
                        "last": 0
                    }
                }
            }
        },
        "Breathe more": {
            "Close the laptop": {
                "time_of_day": {
                    "before": 93600,
                    "after": 21600
                },
                "location": {
                    "region_name": "zelda",
                    "enter_exit": -1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 0.1,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 0.1,
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 0.1,
                        "last": 0
                    }
                }
            }
        }
    },

    /**
"yk":
{
    "Be healthier in body and spirit":
    [
        "Drink one drop of water from fountain",
        "Pray for 30 seconds"
    ]
},
"kap":
{
    "DTR harder":
    [
        "Plan your sprint",
        "Reflect on your DAs"
    ]
},
    */

    /** Real users from here on out */
    "beard":
    {
        "Drink water more consistently": {
            "Fill your water bottle": { // morning, enter kitchen, as he's leaving home
                "time_of_day": {
                    "before": 45000,
                    "after": 28800
                },
                "location": {
                    "region_name": "kitchen",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 240, // not more than once per morning
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 240, // if declined, ignore for rest of morning
                        "last": 0
                    }
                }
            },
            "Go get a glass of water": { // living room for 30 minutes, any time of day
                "time_of_day": {
                    "before": 93600,
                    "after": 21600
                },
                "location": {
                    "region_name": "living room",
                    "enter_exit": 1,
                    "delay": 30
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 180, // hold off for 3hr
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 180, // hold off for 3hr
                        "last": 0
                    }
                }
            },
            "Fill your ice tray with water": { // evening, in kitchen for 10 min
                "time_of_day": {
                    "before": 93600,
                    "after": 61200
                },
                "location": {
                    "region_name": "kitchen",
                    "enter_exit": 1,
                    "delay": 10,
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // accept once per day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 180, // hold off for 3hr
                        "last": 0
                    }
                }
            }
        }
    },
    "indy":
    {
        "Read more consistently": {
            "Read a page of Wuthering Heights": { // late night, enter bedroom
                "time_of_day": {
                    "before": 81900,
                    "after": 79200
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 20, // big gap for 45 min window
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Put Wuthering Heights in your backback": { // early morning, bedroom, 5min after unplug phone
                "time_of_day": {
                    "before": 36000,
                    "after": 21600
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": -1,
                    "delay": 5,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            }
        }
    },
    "spock":
    {
        "Keep a tidier bedroom": { // early morning, when phone unplugged, in bedroom
            "Make your bed": {
                "time_of_day": {
                    "before": 39600,
                    "after": 21600
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": -1,
                    "delay": .1,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Put clothes on the floor into your hamper": { // late night, plug in phone, in bedroom
                "time_of_day": {
                    "before": 93600,
                    "after": 79200
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 1,
                    "delay": .05,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 30,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Pick up your scattered papers": { // 11am-8pm, entering bedroom
                "time_of_day": {
                    "before": 72000.0,
                    "after": 39600.0
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            }
        }
    },
    "gin":
    {
        "Be more mindful of my consumption": { // 9pm-12am, enter kitchen
            "Pack some healthy snacks": {
                "time_of_day": {
                    "before": 86400.0,
                    "after": 75600.0
                },
                "location": {
                    "region_name": "kitchen",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 30,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Fill up my water bottle": { // morning, in kitchen for 3min
                "time_of_day": {
                    "before": 43200.0,
                    "after": 21600.0
                },
                "location": {
                    "region_name": "kitchen",
                    "enter_exit": 1,
                    "delay": 3
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 30,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Check what food you already have": { // 5-9pm, enter kitchen
                "time_of_day": {
                    "before": 75600.0,
                    "after": 61200.0
                },
                "location": {
                    "region_name": "kitchen",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 30,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            }
        }
    },
    "neighbor":
    {
        "Put my clothing away": {
            "Fold the clothes you tried on and threw down": { // morning, in bedroom for 12min
                "time_of_day": {
                    "before": 39600.0,
                    "after": 21600.0
                },
                "location": {
                    "region_name": "bedroom",
                    "enter_exit": 1,
                    "delay": 12
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 30,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Hang up your jacket and align your shoes": { // evening, enter apartment (entryway)
                "time_of_day": {
                    "before": 93600.0,
                    "after": 72000.0
                },
                "location": {
                    "region_name": "entryway",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            },
            "Remove your clothes from the common room": { // 12-8pm, enter living room
                "time_of_day": {
                    "before": 72000.0,
                    "after": 43200.0
                },
                "location": {
                    "region_name": "living room",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 40,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            }
        }
    },
    "gyoza":
    {
        "Floss more regularly": {
            "Floss your back teeth": { // morning, [after phone unplugged?], enter bathroom
                "time_of_day": {
                    "before": 36000.0,
                    "after": 21600.0
                },
                "location": {
                    "region_name": "bathroom",
                    "enter_exit": 1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 60,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off till next day
                        "last": 0
                    }
                }
            }
        },
        "Call my parents more regularly": {
            "Punch in your parent's phone number": { // evening time, leaving house
                "time_of_day": {
                    "before": 77400.0,
                    "after": 54000.0
                },
                "location": {
                    "region_name": "whole house",
                    "enter_exit": -1,
                    "delay": 0
                },
                "plug": {
                    "plug_unplug": 0,
                    "delay": 0,
                },
                "prev_interactions": {
                    "thrown": {
                        "thresh_since_last": 60,
                        "last": 0
                    },
                    "accepted": {
                        "thresh_since_last": 1440, // hold off 24 hours (maybe remind tomorrow, maybe day after, target 4x/wk)
                        "last": 0
                    },
                    "declined": {
                        "thresh_since_last": 720, // hold off 12 hours (remind tomorrow)
                        "last": 0
                    }
                }
            }
        }
    }
}
