function numeric_id_for(element) {
  if (m = element.id.match(/(\d+)$/)) {
    return(m.first());
  } else if (m = element.action.match(/(\d+)\D*$/)) {
    return(m.first());
  }
  return;
}

function previewPart(element,value) {
  new Ajax.Request(preview_part_url({id: numeric_id_for(element)}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}

