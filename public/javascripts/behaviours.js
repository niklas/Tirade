Event.addBehavior.reassignAfterAjax = true
Event.addBehavior({
    'body.role_admin div.grid' : GridEditable,
    'div.grid > div.admin > a': Remote,
    'div.rendering > div.admin > a': Remote.LinkWithToolbox,
    'div.grid a.grid': Remote,
    'div.grid form.update.grid': Remote,
    'div.grid form.destroy.grid': Remote,
    'body.role_admin div.rendering' : ContentEditable,
    'div#toolbox form': Remote,
    'div#toolbox a[href!="#"]': Remote,
    'div#toolbox form.update.rendering': Observed(previewRendering,{frequency: 5}),
    'div#toolbox form.update.content': Observed(previewRendering,{frequency: 5}),
    'div#toolbox form.update.part': Observed(previewRendering,{frequency: 5}),
    'body.role_admin div.grid.yui-u': SortableRenderings,
    'div#toolbox_content #search': Observed(searchAllContents,{frequency: 1}),
    'div#toolbox_content #search_results': SearchResults
});
