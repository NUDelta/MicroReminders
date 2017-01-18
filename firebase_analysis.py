import json
from pprint import pprint

with open('data.json') as data_file:
    data = json.load(data_file)

# Remove Delta iPhone from json
del data['Notifications']['254656F8-DC1A-43C4-80E3-1B64BF7A9681']
del data['Tasks']['254656F8-DC1A-43C4-80E3-1B64BF7A9681']

# Remove prepopulated tasks from json
del data['Tasks']['Prepopulated']

""" Verifying that no notifications were thrown within 15 minutes of each other """
def verify_15min():
    notifications = data['Notifications']
    for user, tasks in notifications.iteritems():
        for task, interactions in tasks.iteritems():
            interactionTimes = sorted([key for key in interactions.keys() if interactions[key] == 'notificationThrown'])
            for i1, i2 in zip(interactionTimes, interactionTimes[1:]):
                diff = int(i2) - int(i1)
                if diff < 15*60:
                    print('Diff b/w thrown for user ' + user + ', task ' + task + ', was ' + str(diff))

def iterate_data(data, *list_pred_tuples):
    for user, tl in data.iteritems():
        for _id, json in tl.iteritems():
            for tup in list_pred_tuples:
                if tup[1](_id, json):
                    tup[0].append((_id, json))

def collect_tasks(*list_pred_tuples):
    tasks = data['Tasks']
    iterate_data(tasks, *list_pred_tuples)

def collect_notification_interactions(*list_pred_tuples):
    notifications = data['Notifications']
    iterate_data(notifications, *list_pred_tuples)

def extract_tasks():
    def entered(_id, task):
        return True

    def completed(_id, task):
        if task['completed'] != 'false':
            return True
        return False

    def custom(_id, task):
        if _id.isupper():
            return True
        return False

    entered_t = ([], entered)
    completed_t = ([], completed)
    custom_t = ([], custom)

    collect_tasks(entered_t, completed_t, custom_t)
    return (entered_t[0], completed_t[0], custom_t[0])

def extract_notification_interactions():
    def entered(_id, notification_dict):
        return True

    entered_t = ([], entered)

    collect_notification_interactions(entered_t)

    thrown = []
    for _id, n_dict in entered_t[0]:
        thrown.extend([(time, kind) for (time, kind) in n_dict.iteritems() if kind == 'notificationThrown'])

    done = []
    for _id, n_dict in entered_t[0]:
        done.extend([(time, kind) for (time, kind) in n_dict.iteritems() if 'Done' in kind])

    snoozed = []
    for _id, n_dict in entered_t[0]:
        snoozed.extend([(time, kind) for (time, kind) in n_dict.iteritems() if kind == 'notificationSnoozed'])

    return (thrown, done, snoozed)



if __name__ == '__main__':
    (thrown, done, snoozed) = extract_notification_interactions()
    message = '{0} notifications thrown, {1} times marked done, {2} tmes snoozed'.format(len(thrown), len(done), len(snoozed))

    # (entered, completed, custom) = extract_tasks()
    # message = '{0} tasks entered, {1} completed, {2} custom'.format(len(entered), len(completed), len(custom))

    print(message)
