Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    'body.role_admin div.grid' : GridEditable,
    'div.admin a': Remote,
    'div.grid a.grid': Remote,
    'div.grid form.update.grid': Remote,
    'div.grid form.destroy.grid': Remote,
    'form.part' : Observed(previewPart,{frequency: 5})
});
