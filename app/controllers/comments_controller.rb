class CommentsController < ApplicationController
    before_action :authenticate_user!

    def create
        @ticket = Ticket.find(params[:ticket_id])
        @comment = @ticket.comments.build(comments_params)
        @comment.user = current_user

        if @comment.save
            redirect_to @ticket, notice: "Comentário adicionado com sucesso."
        else
            redirect_to @ticket, notice: "Comentário não pode ficar em branco."
        end
    end

    private

    def comments_params
        params.require(:comment).permit(:body)
    end
end
