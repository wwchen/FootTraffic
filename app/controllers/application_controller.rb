class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_domain

  APP_DOMAIN = 'foottraffic.iamchen.com'

  def ensure_domain
    if request.env['HTTP_HOST'] != APP_DOMAIN && !request.env[ 'HTTP_HOST' ].include?('localhost')
      # HTTP 301 is a "permanent" redirect
      redirect_to "http://#{APP_DOMAIN}", :status => 301
    end
  end
end
