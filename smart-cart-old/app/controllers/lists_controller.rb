class ListsController < ApplicationController
  before_action :set_list, only: %i[ show edit update destroy ]

  $list = []
  # GET /lists or /lists.json
  def index
    @lists = List.all
    # @list = []
    # @current_list = $list
    $session_id = session[:current_user_id]
  end

  # GET /lists/1 or /lists/1.json
  def show
    @current_list = $list
  end

  # GET /lists/new
  def new
    @list = List.new
    # @list = []
  end

  # GET /lists/1/edit
  def edit
    
  end

  # POST /lists or /lists.json
  def create
    # @list = List.new(list_params)

    # respond_to do |format|
    #   if @list.save
    #     format.html { redirect_to list_url(@list), notice: "List was successfully created." }
    #     format.json { render :show, status: :created, location: @list }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @list.errors, status: :unprocessable_entity }
    #   end
    # end

    List.create(list_id: $session_id, item: params[:item], quantity: 1)

    if ($list.length >= 1) 
      $list.push(params[:item])
      redirect_to lists_path, notice: 'List was successfully updated.'
    else 
      $list.push(params[:item]) 
      redirect_to lists_path, notice: 'List was successfully created.'
    end

    # @list = List.new(params.require(:list).permit(:item))

    

  end

  # PATCH/PUT /lists/1 or /lists/1.json
  def update
   
    @list = List.find_by(list_id: $session_id, item: params[:item])
    @list.update(list_params)
    redirect_to lists_path

    # respond_to do |format|
    #   if @list.update(list_params)
    #     format.html { redirect_to list_url(@list), notice: "List was successfully updated." }
    #     format.json { render :show, status: :ok, location: @list }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @list.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /lists/1 or /lists/1.json
  def destroy
    @list = List.find_by(list_id: $session_id, item: params[:item])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_url, notice: "Item was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def add_item
    # @list = List.new(list_params)
    
    # if @list.save
    #   redirect_to list_url(1), notice: 'List was successfully updated.'
    # else

    # end
  end 

  def delete_item
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      # @list = List.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def list_params
      params.require(:list).permit(:item, :quantity, :list_id)
    end

end
