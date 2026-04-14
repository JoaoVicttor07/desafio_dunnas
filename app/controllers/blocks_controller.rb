class BlocksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_block, only: %i[edit update destroy]

  # GET /blocks
  def index
    @blocks = Block.all
  end

  # GET /blocks/new
  def new
    @block = Block.new
  end

  # GET /blocks/1/edit
  def edit
  end

  # POST /blocks
  def create
    @block = Block.new(block_params)

    if @block.save
      redirect_to blocks_path, notice: "Bloco criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /blocks/1
  def update
    if @block.update(block_params)
      redirect_to blocks_path, notice: "Bloco atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /blocks/1
  def destroy
    @block.destroy!
    redirect_to blocks_path, notice: "Bloco removido com sucesso.", status: :see_other
  end

  private

  def set_block
    @block = Block.accessible_by(current_ability).find(params[:id])
  end

  def block_params
    params.require(:block).permit(:identification, :floors_count, :apartments_per_floor)
  end
end
