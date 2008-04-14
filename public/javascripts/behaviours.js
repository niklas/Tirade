Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    'body.role_admin div.grid' : GridEditable,
    'div.admin a': Remote,
    'div.grid a.show.grid': Remote,
    'div.grid form.update.grid': Remote
});
