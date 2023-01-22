class ListsController < ApplicationController
  before_action :set_list, only: %i[ show edit update destroy ]

  $list = []
  # GET /lists or /lists.json
  def index
    # @lists = List.all
    @list = []
    @current_list = $list
  end

  # GET /lists/1 or /lists/1.json
  def show
    @current_list = $list
  end

  # GET /lists/new
  def new
    # @list = List.new
    @list = []
  end

  # GET /lists/1/edit
  def edit
    @current_list = $list[params[:id].to_i]
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
   
    if ($list.length >= 1) 
      $list.push(params[:item])
      redirect_to lists_path, notice: 'List was successfully updated.'
    else 
      $list.push(params[:item]) 
      redirect_to lists_path, notice: 'List was successfully created.'
    end
  end

  # PATCH/PUT /lists/1 or /lists/1.json
  def update
    # respond_to do |format|
    #   if @list.update(list_params)
    #     format.html { redirect_to list_url(@list), notice: "List was successfully updated." }
    #     format.json { render :show, status: :ok, location: @list }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @list.errors, status: :unprocessable_entity }
    #   end
    # end

    @current_list = $list[params[:id].to_i]
    @current_list << [params[:item]]
    $list.push(@current_list)
    redirect_to list_url(1), notice: 'List was successfully updated.'
  end

  # DELETE /lists/1 or /lists/1.json
  def destroy
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_url, notice: "List was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      # @list = List.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def list_params
      params.fetch(:list, {})
    end
end
