class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.includes(:actor, :ticket).recent.limit(100)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    redirect_back fallback_location: notifications_path
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    redirect_to notifications_path, notice: "Todas as notificações foram marcadas como lidas."
  end
end
