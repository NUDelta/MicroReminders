# MicroReminders

Built by Sasha Weiss in the Delta Lab at Northwestern University, as part of the DTR (Design, Technology, and Research) research program.

Advisors: Prof. Haoqi Zhang and Yongsung Kim.

## Overview

How do we encourage people to get more "stuff" done around the house? With MicroReminders I hope to target small (minute-long), around-the-house tasks that can be accomplished in the existing dead space of people's routines.

I hope that by presenting iOS notifications at particular contexts (specifically, location as determined by Estimote iBeacons) I can encourage users to remember and complete the aforementioend "microtasks", small chores that tend to slip our minds. This space invites a number of critical questions, including (but certainly not limited to):

- What sort of tasks are accomplishable without disrupting existing routines?
- What are the parameters of the context in which they are accomplishable?
- How can we accurately infer that context?
- Can microtask completion serve as a catalyst or incremental strategy for completing larger, more complex, or lingering tasks?

This app serves as a system for investigating these questions, and for exploring what affordances best help more tasks ultimately get done.

## Building and running
MicroReminders relies on iBeacon technology, and so both beacons and a physical device with bluetooth enabled are required to effectively use the app.

To run MicroReminders:
1) Verify that you have an appropriate code-signing certificate and permissions.
2) Open MicroReminders.xcworkspace in Xcode.
3) Update the Beacons singleton to represent the identifiers and minors of your beacons. At present, all beacons are assumed to have same UUID and major.
4) Build to a physical device.
