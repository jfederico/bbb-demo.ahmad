require 'bigbluebutton_api'

class PagesController < ApplicationController
  def home
    intialize_api_connection

    @current_rooms_created = @api.get_meetings

    @current_recordings = @api.get_recordings
  end

  def create_and_join_meeting
    intialize_api_connection

    record = false

    record = true if request.params[:record]

    create_room(request.params[:room_id], record)

    join_room(request.params[:name], request.params[:password])
  end

  def intialize_api_connection
    url = 'http://10.8.186.201/bigbluebutton/api'
    secret = 'eae6b20cd43c742e3f89b49eebfeeaf1'
    version = 0.81

    @api = BigBlueButton::BigBlueButtonApi.new(url, secret, version.to_s, true)
  end

  def create_room(room_id = 'default-room-id', record = false)
    @meeting_name = room_id.tr('-', ' ').titleize
    @meeting_id = room_id
    @options = {
      moderatorPW: 'mp',
      attendeePW: 'ap',
      record: record.to_s,
      autoStartRecording: record.to_s,
      logoutURL: 'http://localhost:3000'
    }

    if @api.is_meeting_running?(@meeting_id)
      puts 'Meeting already running'
    else
      response = @api.create_meeting(@meeting_name, @meeting_id, @options)
      puts 'The meeting has been created'
    end
  end

  def join_room(username, password)
    url = @api.join_meeting_url(@meeting_id, username, password)
    redirect_to url.to_s
  end
end
