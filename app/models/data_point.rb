class DataPoint < ActiveRecord::Base
  belongs_to :metric, inverse_of: :data_points, touch: :latest_data_point_at,
    counter_cache: true
  belongs_to :user, inverse_of: :data_points

  validates :metric, presence: true, strict: true
  validates :number, :user, presence: true
  validates :number, numericality: true

  def self.from_slash_command(payload)
    metric = Metric.from_slash_command(payload)
    user = User.from_slash_command(payload, metric: metric)

    match = metric.regexp.match(payload[:text])
    number = match.names.include?("number") && match[:number] || 1
    metadata = payload.merge(Hash[match.names.zip(match.captures)])
    metadata.update(number: number, user: user.slack_name)

    DataPoint.create(
      metric: metric,
      user: user,
      number: number,
      metadata: metadata
    )
  end

  def feedback
    metric.feedback % metadata.symbolize_keys
  end
end
