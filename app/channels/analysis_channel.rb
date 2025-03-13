class AnalysisChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'analysis_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Traiter les données reçues du client si nécessaire
  end
end
