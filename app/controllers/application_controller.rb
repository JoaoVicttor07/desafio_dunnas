class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do
    target = (user_signed_in? && current_user.administrator?) ? authenticated_root_path : tickets_path
    redirect_to target, alert: "Acesso Negado: Você não tem permissão para acessar esta página."
  end

  def after_sign_in_path_for(resource)
    return authenticated_root_path if resource.respond_to?(:administrator?) && resource.administrator?
    return tickets_path if resource.respond_to?(:collaborator?) && resource.collaborator?
    return tickets_path if resource.respond_to?(:resident?) && resource.resident?
    super
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
