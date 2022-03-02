module ApplicationHelper

  def body_classes
    controller_class  = controller.controller_name.parameterize
    action_class      = controller.action_name.parameterize
    "#{controller_class} #{controller_class}-#{action_class}"
  end

  def has_pending_booking?
    @_has_pending_booking ||= Booking.pending.for(current_or_guest_user).any?
  end

  def meta_title_for(title, site)
    title ||= t("meta.title.#{resource_locale_key}", default: '')

    return "#{site} - #{t('meta.title.default')}" if title.blank?

    title.include?(site) ?  title : "#{title} - #{site}"
  end

  def meta_description_for(description)
    description.blank? ? t("meta.description.#{resource_locale_key}", default: :'meta.description.default') : description
  end

  def resource_locale_key
    [params[:controller], params[:action], params[:id]].select(&:present?).join('.').parameterize('.').sub('high_voltage.', '').sub('.show', '')
  end

  def user_locale_key
    current_or_guest_user.guest? ? 'guest' : 'user'
  end

end
