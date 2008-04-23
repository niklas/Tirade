var Toolbox = Class.create({ 
  initialize: function(element, url, options) {
    this.options = options || { };
    this.options.cornerRadius     = options.cornerRadius      || 6 ;
    this.options.headerHeight     = options.headerHeight      || 30 ;
    this.options.headerStartColor = options.headerStartColor  || [250, 250, 250] ;
    this.options.headerStopColor  = options.headerStopColor   || [228, 228, 228] ;
    this.options.bodyBgColor      = options.bodyBgColor       || [240, 240, 240] ;
    this.options.loadMethod       = options.loadMethod        || 'xhr'

    this.element        = $(element)
    this.contentURL     = url || ''
		this.shadowWidth    = 3;
		this.shadowOffset   = this.shadowWidth * 2;		
    this.canvas;
    this.width          = 300;
    this.radius         = 6;
    this.height         = 400;
    this.footerHeight   = 30
    this.contentHeight  = this.height - this.footerHeight - this.options.headerHeight
    this.contentWidth   = this.width-2*(2*this.shadowWidth-1+this.shadowWidth)
    this.toolbox;
    this.setup();
  },
  
  setup: function() {
    // remove existing toolbox
    if ( $('toolbox') )
      $('toolbox').remove();

    this.drawWindow();
    this.toolbox = Builder.node('div' , { id: 'toolbox', title: 'toolbox', style: 'position:absolute;height:' + this.height + 'px; width:' + this.width + 'px' },
      [ 
        Builder.node('div', {style: 'position:absolute;' }, 
        [
          Builder.node('h3',  { title: 'content',       style: 'cursor:move;padding:0 0 0 10px;margin:0 0 0 2px;width:'+this.contentWidth+'px;line-height:'+this.options.headerHeight+'px;'},  'header'  ),
          Builder.node('div', { id: 'toolbox_conten',   style: 'border-bottom:1px solid #D7D7D7;border-top:1px solid #BDBDBD;background:#fff;overflow-y:auto;padding:0 0 0 10px;margin: 0 0 0 '+this.shadowWidth+'px;width:'+ this.contentWidth +'px;height:'+this.contentHeight+'px;'},  'content' ),
          Builder.node('div', { title: 'footer',        style: 'padding:0 0 0 10px;margin:0;width:'+this.contentWidth+'px;line-height:'+this.footerHeight+'px;'},  ''  ),
        ] )
      ]);
    this.toolbox.appendChild(this.canvas)
    new Draggable(this.toolbox, { handle: this.toolbox.down('h3') });
    this.getContent();
    this.element.insert(this.toolbox);
  },
  
  /*
  Method:        draw Window
  Description:   description of method
  */
  drawWindow: function(){
    this.canvas = new Element('canvas', {  'width': this.width, 'height': this.height });
    var ctx = this.canvas.getContext('2d');
    
    // drop shadow
    this.roundedRect(ctx, 0, 0, this.width,     this.height,      this.options.cornerRadius, [0, 0, 0], 0.06  ); 
		this.roundedRect(ctx, 1, 1, this.width - 2, this.height - 2,  this.options.cornerRadius, [0, 0, 0], 0.08  );
		this.roundedRect(ctx, 2, 2, this.width - 4, this.height - 4,  this.options.cornerRadius, [0, 0, 0], 0.3   ); 
		
    //body
    this.bodyRoundedRect(
			ctx,							                  // context		
			this.shadowWidth,                   // x
			2,                                  // y			
			this.width  - this.shadowOffset,    // width
			this.height - this.shadowOffset,    // height
			this.options.cornerRadius,          // corner radius
			this.options.bodyBgColor            // Footer color
		);

		// header
		this.topRoundedRect(				
			ctx,							                // context
			this.shadowWidth,                 // x
			2,                                // y
			this.width  - this.shadowOffset,  // width
			this.options.headerHeight,        // height
			this.options.cornerRadius,        // corner radius
			this.options.headerStartColor,    // Header gradient's top color
			this.options.headerStopColor      // Header gradient's bottom color
		);
  },

  /*
  Method:        body Rounded Rect
  Description:   ?
  */
	bodyRoundedRect: function(ctx, x, y, width, height, radius, rgb){
		ctx.fillStyle = 'rgba(' + rgb.join(',') + ', 100)';
		ctx.beginPath();
		ctx.moveTo(x, y + radius);
		ctx.lineTo(x, y + height - radius);
		ctx.quadraticCurveTo(x, y + height, x + radius, y + height);
		ctx.lineTo(x + width - radius, y + height);
		ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - radius);
		ctx.lineTo(x + width, y + radius);
		ctx.quadraticCurveTo(x + width, y, x + width - radius, y);
		ctx.lineTo(x + radius, y);
		ctx.quadraticCurveTo(x, y, x, y + radius);
		ctx.fill(); 
	},

	topRoundedRect: function(ctx, x, y, width, height, radius, headerStartColor, headerStopColor){
		// Create gradient
		var lingrad = ctx.createLinearGradient(0, 0, 0, this.options.headerHeight);

		lingrad.addColorStop(0, 'rgba(' + headerStartColor.join(',') + ', 100)');
		lingrad.addColorStop(1, 'rgba(' + headerStopColor.join(',') + ', 100)');
		ctx.fillStyle = lingrad;

		// Draw header
		ctx.beginPath();
		ctx.moveTo(x, y);
		ctx.lineTo(x, y + height);
		ctx.lineTo(x + width, y + height);
		ctx.lineTo(x + width, y + radius);
		ctx.quadraticCurveTo(x + width, y, x + width - radius, y);
		ctx.lineTo(x + radius, y);
		ctx.quadraticCurveTo(x, y, x, y + radius);
		ctx.fill(); 
	},

	roundedRect: function(ctx, x, y, width, height, radius, rgb, a){
		ctx.fillStyle = 'rgba(' + rgb.join(',') + ',' + a + ')';
		ctx.beginPath();
		ctx.moveTo(x, y + radius);
		ctx.lineTo(x, y + height - radius);
		ctx.quadraticCurveTo(x, y + height, x + radius, y + height);
		ctx.lineTo(x + width - radius, y + height);
		ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - radius);
		ctx.lineTo(x + width, y + radius);
		ctx.quadraticCurveTo(x + width, y, x + width - radius, y);
		ctx.lineTo(x + radius, y);
		ctx.quadraticCurveTo(x, y, x, y + radius);
		ctx.fill(); 
	},

	/*
	Method:        get content
	Description:   ajax/ifram/...
	*/
	getContent: function(){
    new Ajax.Updater( 'toolbox_content', this.contentURL );
	},
});


