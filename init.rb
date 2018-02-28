# frozen_string_literal: true

module RailsWagonInitializer
  #
  # Manages getting data from the user
  class InteractionService
    MAX_NUMBER_OF_RETRIES = 5

    #
    # Service starts here
    def run
      uses_devise = user_uses_devise?
      uses_clever_cloud = user_uses_clever_cloud?
      app_name = ask_user_for_app_name

      writing_service = RailsWagonInitializer::FinalCommandWritingService
      writing_service.new.run(uses_devise, uses_clever_cloud, app_name)
    end

    private

    def user_uses_devise?
      question = 'Will you use devise for auth and/or need a user model? (y/n)'
      response_positive?(ask_user(question))
    end

    def user_uses_clever_cloud?
      question = 'Will you use Clever Cloud instead of Heroku? (y/n)'
      response_positive?(ask_user(question))
    end

    def ask_user_for_app_name
      puts 'what is your app name? (format: my_app_name)'
      gets.chomp
    end

    def ask_user(string)
      retry_count = 0

      while retry_count <= MAX_NUMBER_OF_RETRIES
        puts 'Response not recognized, please retry' if retry_count.positive?
        puts string
        response = gets.chomp
        break if response_valid?(response)
        retry_count += 1
      end

      raise_too_many_tries! if retry_count > MAX_NUMBER_OF_RETRIES

      response
    end

    def response_valid?(response)
      return false unless response.respond_to?(:downcase) && response[0]
      %w[y n].include?(response[0]&.downcase)
    end

    def response_positive?(response)
      %w[y].include?(response[0].downcase)
    end

    def raise_too_many_tries!
      puts 'response not recognized - try again'
      raise
    end
  end

  #
  # Manages what to write in the command line to generate template
  # once the options have been chosen
  class FinalCommandWritingService
    def run(uses_devise, uses_clever_cloud, app_name)
      cmd = final_shell_command(uses_devise, uses_clever_cloud, app_name)
      exec(cmd)
    end

    private

    def final_shell_command(uses_devise, uses_clever_cloud, app_name)
      "
      rails new \
        --database postgresql \
        --webpack \
        -m #{template_url(uses_devise, uses_clever_cloud)} \
        #{safe_app_name(app_name)}
      "
    end

    def template_url(uses_devise, uses_clever_cloud)
      devise_string = uses_devise ? 'devise' : 'minimal'
      clever_cloud_string = uses_clever_cloud ? 'clever_cloud/' : ''

      file_path = "#{clever_cloud_string}#{devise_string}.rb"

      "https://raw.githubusercontent.com/lewagon/rails-templates/master/#{file_path}"
    end

    def safe_app_name(app_name)
      app_name.tr(' ', '_')
    end
  end
end

RailsWagonInitializer::InteractionService.new.run
