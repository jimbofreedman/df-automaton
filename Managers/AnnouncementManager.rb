class AnnouncementManager < Manager
  def initialize()
    puts "Initializing AnnouncementManager"

    @lastAnnounce = 0
  end

  def process()
    doProcess()
  end

  def doProcess()
    @lastAnnounce ||= 0
    #puts "Checking pastures"
    while (@lastAnnounce <= df.world.status.announcements.length)
      handleAnnouncement(df.world.status.announcements[@lastAnnounce])
      @lastAnnounce = @lastAnnounce + 1
    end
  end

  def handleAnnouncement(announcement)
    if (announcement == nil)
      return
    end
    
    if (announcement.type != :REACHED_PEAK &&
      announcement.type != :CANCEL_JOB &&
      announcement.type != :DIG_CANCEL_DAMP &&
      announcement.type != :STRUCK_MINERAL &&
      announcement.type != :PROFESSION_CHANGES)
      case announcement.type
      when :CARAVAN_ARRIVAL
        @depot = df.world.buildings.all.find do |b| b.class.to_s == "DFHack::BuildingTradedepotst" end
        # if (@depot != nil)
        #   @depot.trade_flags.trader_requested = true
        # end
      end
      puts(announcement.inspect)
    end
  end

  def statechanged(st)
    # automatically unpause the game (only for game-generated pauses)
    if st == :PAUSED and
            la = df.world.status.announcements.to_a.reverse.find { |a|
                df.announcements.flags[a.type].PAUSE rescue nil
            } and la.year == df.cur_year and la.time == df.cur_year_tick
        handle_pause_event(la)

    elsif st == :VIEWSCREEN_CHANGED
        case cvname = df.curview._rtti_classname
        when :viewscreen_textviewerst
            text = df.curview.formatted_text.map { |t|
                t.text.to_s.strip.gsub(/\s+/, ' ')
            }.join(' ')

            if text =~ /I am your liaison from the Mountainhomes\. Let's discuss your situation\.|Farewell, .*I look forward to our meeting next year\.|A diplomat has left unhappy\./
                puts "AI: exit diplomat textviewerst (#{text.inspect})"
                timeout_sameview {
                    df.curview.feed_keys(:LEAVESCREEN)
                }

            elsif text =~ /A vile force of darkness has arrived!/
                puts "AI: siege (#{text.inspect})"
                timeout_sameview {
                    df.curview.feed_keys(:LEAVESCREEN)
                    df.pause_state = false
                }

            elsif text =~ /Your strength has been broken\.|Your settlement has crumbled to its end\./
                puts "AI: you just lost the game:", text.inspect, "Exiting AI."
                onupdate_unregister
                # dont unpause, to allow for 'die'

            else
                puts "AI: paused in unknown textviewerst #{text.inspect}" if $DEBUG
            end

        when :viewscreen_topicmeetingst
            timeout_sameview {
                df.curview.feed_keys(:OPTION1)
            }
            #puts "AI: exit diplomat topicmeetingst"

        when :viewscreen_topicmeeting_takerequestsst, :viewscreen_requestagreementst
            puts "AI: exit diplomat #{cvname}"
            timeout_sameview {
                df.curview.feed_keys(:LEAVESCREEN)
            }

        else
            @seen_cvname ||= { :viewscreen_dwarfmodest => true }
            puts "AI: paused in unknown viewscreen #{cvname}" if not @seen_cvname[cvname] and $DEBUG
            @seen_cvname[cvname] = true
        end
    end
  end

  def timeout_sameview(delay=1, &cb)
      curscreen = df.curview._rtti_classname
      timeoff = Time.now + delay

      df.onupdate_register_once('timeout') {
          next true if df.curview._rtti_classname != curscreen

          if Time.now >= timeoff
              cb.call
              true
          end
      }
  end

  def onupdate_register
      @pop.onupdate_register
      @plan.onupdate_register
      @stocks.onupdate_register
      @status_onupdate = df.onupdate_register('df-ai status', 3*28*1200, 3*28*1200) { puts status }

      df.onstatechange_register_once { |st|
          case st
          when :WORLD_UNLOADED
              puts 'AI: world unloaded, disabling self'
              onupdate_unregister
              true
          else
              statechanged(st)
              false
          end
      }
  end

  def status()
    puts "Announcement Status"
  end
end

puts "Loaded class AnnouncementManager"
