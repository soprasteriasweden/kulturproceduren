require 'csv'

# Controller for showing global statistics
class StatisticsController < ApplicationController

  layout "admin"
  before_filter :authenticate

  # Shows available statistics grouped by term
  def index
    @terms = get_available_terms()
  end
  

  # Shows all events for a given term. It can also be used to download
  # or view visitors stats for a given event.
  def visitors

    @term = params[:id]
    @events = get_available_events(@term)

    # Only fetch statistics for a specific event or when downloading statistics as an .xls file.
    if !params[:event_id].nil? || params[:format] == "xls"

      if !params[:event_id].nil?
        @visitor_stats = Event.get_visitor_stats_for_events([Event.find_by_id(params[:event_id].to_i)])
      else
        @visitor_stats = Event.get_visitor_stats_for_events(@events)
      end

        puts "hello"
      # Output an xls file
      if params[:format] == "xls"
        xls_string =  get_visitor_stats_as_csv(@visitor_stats)
        send_data xls_string, :filename => "visitors_stats_#{@term}.xls",:type => "application/xls" , :disposition => 'inline'
      end
      
    end

  end


  
  private

  # Returns all avaiable terms in an array
  # The format of a term is "ht|vtYYYY", e.g. ht2007 (autumn term 2007)
  # vt = vårtermin. ht = hösttermin
  def get_available_terms

    # Begins at fall 2001
    available_terms = []
    2009.upto(Time.now.year.to_i) do |year|

      num_vt = Occasion.count :all, :conditions => "date between '#{year}-01-01' and '#{year}-06-30'"
      num_ht = Occasion.count :all, :conditions => "date between '#{year}-07-01' and '#{year}-12-31'"

      available_terms << "vt#{year}" if num_vt > 0
      available_terms << "ht#{year}" if num_ht > 0
      
    end

    return available_terms
  end


  # Returns all available events for a given term
  # The format of a term is "ht|vtYYYY", e.g. ht2007 (autumn term 2007)
  def get_available_events(term)
    term, year = term.scan(/^(vt|ht)(20[01][0-9])$/).first

    if term == 'vt'
      from = "#{year}-01-01"
      to = "#{year}-06-30"
    else
      from = "#{year}-07-01"
      to = "#{year}-12-31"
    end


    Event.find :all, :include => :culture_provider,
      :conditions => [ "events.id in (select event_id from occasions where occasions.date between ? and ?)", from, to ]
  end


  # Returns a comma-seperated values (CSV) string
  def get_visitor_stats_as_csv(visitor_stats)

    output_buffer = get_csv_headers_for_visitor_stats(visitor_stats)

    visitor_stats.each do |visitor_group_stats|

      row = [visitor_group_stats[:district].name, visitor_group_stats[:school].name, visitor_group_stats[:group].name ]

      visitor_group_stats[:stats_per_event].each do |stats_for_event|

        row = row + [stats_for_event[:booked_tickets], stats_for_event[:used_tickets_children],
                     stats_for_event[:used_tickets_adults]]
      end
      CSV.generate_row(row, row.length, output_buffer)
    end

    return output_buffer
  end

  def get_csv_headers_for_visitor_stats(visitor_stats)

    output_buffer = ''

    # Add headers
    row1 = ["","",""]
    row2 = ["Stadsdel", "Skola", "Grupp"]#, "Antal bokade", "Antal barn", "Antal vuxna"]

    events = visitor_stats.first[:stats_per_event]
    events.each do |event|
      row1 = row1 + ["#{event[:event].name}", "", ""]
      row2 = row2 + ["Antal bokade", "Antal barn", "Antal vuxna"]
    end

    CSV.generate_row(row1, row1.length, output_buffer)
    CSV.generate_row(row2, row2.length, output_buffer)

    return output_buffer
  end
end
