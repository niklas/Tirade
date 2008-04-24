function numeric_id_for(element) {
  if (m = element.id.match(/(\d+)$/)) {
    return(m.last());
  } else if (m = element.action.match(/(\d+)\D*$/)) {
    return(m.last());
  }
  return;
}

function previewPart(element,value) {
  new Ajax.Request(preview_part_url({id: numeric_id_for(element)}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}
function previewRenderingPart(element,value) {
  new Ajax.Request(preview_rendering_part_url({rendering_id: numeric_id_for(element)}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}
