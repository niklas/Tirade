function previewPart(element,value) {
  new Ajax.Request(preview_part_url({id: 2}), 
        {asynchronous:true, evalScripts:true, parameters:value});
}

