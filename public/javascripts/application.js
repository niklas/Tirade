function numeric_id_for(element) {
  if (m = element.id.match(/(\d+)$/)) {
    return(m.last());
  } else if (m = element.getElementsBySelector('a.rendering').first().href.match(/(\d+)$/)) {
    return(m.last());
  } else if (m = element.action.match(/(\d+)\D*$/)) {
    return(m.last());
  }
  return;
}

function previewPart(element,value) {
  new Ajax.Request(Routing.preview_part_url({id: numeric_id_for(element)}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}
function previewRendering(element,value) {
  rendering_id = element.getElementsBySelector('a.rendering').first().href.match(/(\d+)$/).last();
  new Ajax.Request(Routing.preview_rendering_url({id: rendering_id}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}

function searchAllContents(element,value) {
  rendering_id = numeric_id_for($$('#toolbox_content form.edit_rendering').first());
  // TODO escape
  new Ajax.Request(Routing.new_rendering_content_url({rendering_id: rendering_id}), 
      {method: 'get', asynchronous:true, evalScripts:true, parameters:'term=' + value}
  );
}
function searchImages(element,value) {
  // TODO escape
  new Ajax.Request(Routing.images_url(), 
      {method: 'get', asynchronous:true, evalScripts:true, parameters:'for_select=1&term=' + value}
  );
}
