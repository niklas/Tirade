class GridsController < ManageResourceController::Base
  # TODO spec and make work again
  before_filter :login_required
  #before_filter :fetch_associated_rendering, :only => [:edit, :update]
  before_filter :fetch_grid, :except => [:index, :new, :create]
  
  # FIXME (must be done in ressourcefull_views plugin)
  protect_from_forgery :except => [:destroy,:order_renderings, :order_children]

  def update_page_on_create(page)
    super
    if thepage = @context_page
      page.focus_on(thepage)
      page.clear
      page.insert_page(thepage)
    end
  end

  def update_page_on_destroy(page)
    super
    page.select_grid(object).remove
  end

  def update_page_on_preview(page)
    super
    page.update_grid_in_page(object, @context_page) if @context_page
  end

  def update_page_on_update(page)
    super
    page.update_grid_in_page(object, @context_page) if @context_page
  end

  # Remove this Grid an all its siblings, placing their children into its parent
  # TODO refresh the parent on the current page
  def explode
    if @grid.leaf?
      @grid.explode!
      flash[:notice] = "please reload page"
    else
      flash[:error] = "Could not explode, Grid is no leaf (has Grids below it)"
    end
  end

  def order_renderings
    unless params[:rendering].blank?
      Rendering.transaction do
        renderings_ids = params[:rendering].reject(&:blank?)
        @old_grids = Grid.find(Rendering.find(renderings_ids).map(&:grid_id).uniq)
        renderings_ids.andand.each_with_index do |id,index|
          Rendering.update_all(%Q~position = #{index+1},grid_id=#{@grid.id}~, ['id = ?', id])
        end
      end
      refresh @old_grids + [@grid]
    else
      refresh
    end
  end

  def order_children
    unless params[:grid].blank?
      Grid.transaction do
        grids_ids = params[:grid].reject(&:blank?)
        @old_grids = []
        Grid.find(grids_ids).map(&:parent).uniq
        grids_ids.andand.each_with_index do |gid,i|
          child = Grid.find(gid)
          @old_grids << child.parent
          child.move_to_parent_location @grid, i
        end
      end
      refresh @old_grids + [@grid]
    else
      refresh
    end
  end

  def update_page_on_show(page)
    super
    page.focus_on(@grid)
  end

  private
  def refresh(grids=[@grid])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          grids.uniq.each do |grid|
            if @context_page
              page.select_grid(grid).replace_with(render_grid_in_page(grid, @context_page))
              page.select("div#toolbox > div.body > div.content ul.tree.tree_root li.grid.#{page.context.dom_id grid}").
                replace_with(render_tree_node(grid, :page => @context_page))
            end
          end
        end
      end
    end
  end
  def fetch_grid
    @model = @grid = Grid.find(params[:id])
  end
  def collection_of_roots # disabled
    end_of_association_chain.roots
  end

end
