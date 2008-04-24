Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    'body.role_admin div.grid' : GridEditable,
    'div.admin a': Remote,
    'div.grid a.grid': Remote,
    'div.grid form.update.grid': Remote,
    'div.grid form.destroy.grid': Remote,
    'body.role_admin div.rendering' : ContentEditable,
    'div.admin'     : Toolbox,
    'div#toolbox form': Remote,
    'div#toolbox a': Remote,
    'div#toolbox form.update': Observed(previewRendering,{frequency: 5}),
    'body.role_admin div.grid.yui-u': SortableRenderings
});
