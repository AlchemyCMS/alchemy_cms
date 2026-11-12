# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Liquid::Filters#format_date", type: :helper do
  let(:time) { Time.zone.local(2026, 11, 12, 9, 30) }

  it "localizes a time with the default format" do
    expect(render_liquid("{{ time | format_date }}", time: time)).to eq(I18n.l(time))
  end

  it "localizes with a given format" do
    expect(render_liquid('{{ time | format_date: "short" }}', time: time)).to eq(I18n.l(time, format: :short))
  end

  it "localizes dates" do
    date = time.to_date
    expect(render_liquid('{{ date | format_date: "long" }}', date: date)).to eq(I18n.l(date, format: :long))
  end

  it "parses strings" do
    expect(render_liquid('{{ "2026-11-12 09:30" | format_date: "short" }}')).to eq(I18n.l(time, format: :short))
  end

  it "returns nothing for blank or invalid values" do
    expect(render_liquid('[{{ "" | format_date }}{{ "nope" | format_date }}{{ nil | format_date }}]')).to eq("[]")
  end
end
