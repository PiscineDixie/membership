module EmailHelper
    def email_image_url(name)
        #url_opts = Rails.application.config.action_mailer.default_url_options
        #host = url_opts[:host]
        #prot  = url_opts[:protocol] || 'http'
        #byebug
        url = image_url(name)
        url
    end
end