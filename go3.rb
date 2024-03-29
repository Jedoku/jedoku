  #!/usr/bin/env ruby

  require 'fox16'
  require_relative 'data/icons/pid'
  require 'win32ole'
  require 'win32/sound'
  include Win32
  include Fox

  class MainWindow < FXMainWindow
    
    def initialize(app)
      super(app, "Логопедійка",:opts => DECOR_ALL, :width => 400, :height => 200)
    
      def iconMain
        filename = File.expand_path("../data/i.ico", __FILE__)
          File.open(filename, "rb") do |f|
            FXICOIcon.new(getApp(), f.read)
          end
      end
      self.icon = iconMain
      self.miniIcon = iconMain

      def loadIcon(fold,filename)
        filename = File.expand_path("../data/#{fold}/#{filename}.png", __FILE__)
          File.open(filename, "rb") do |f|
            FXPNGIcon.new(getApp(), f.read)
          end
      end
      
      @acces = 0
    wmi = WIN32OLE.connect("winmgmts://")

    devices = wmi.ExecQuery("Select * From Win32_USBControllerDevice")
    for device in devices do
    device_name = device.Dependent.gsub('"', '').split('=')[1]
    usb_devices = wmi.ExecQuery("Select * From Win32_PnPEntity Where DeviceID = '#{device_name}'")
    for usb_device in usb_devices do
        puts usb_device.Description
        if usb_device.PNPDeviceID == $usbf
            @acces = 1
          end
      end
    end
    exit_ico = loadIcon('icons','exit')
    case @acces

    when 0 
      quitframe = FXVerticalFrame.new(self, :opts => LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
      
      FXLabel.new(quitframe,"Для продовження вставте Ліцензійну флешку та перезапустіть гру.", :opts => LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
      FXLabel.new(quitframe,"Придбати гру ви можете на сайті: logopedijka.live", :opts => LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
      quitButton = FXButton.new(quitframe,nil,exit_ico,
        :opts => FRAME_GROOVE|FRAME_THICK|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|LAYOUT_CENTER_Y)
      quitButton.connect(SEL_COMMAND) { getApp().exit(0) }
    when 1

      full_screen_main = FXVerticalFrame.new(self, LAYOUT_SIDE_TOP|FRAME_NONE|LAYOUT_FILL_X|LAYOUT_FILL_Y|PACK_UNIFORM_WIDTH)
      app.baseColor = Fox.FXRGB(255,255,255)
      app.backColor = Fox.FXRGB(255,255,255)
      @fontcourier = FXFont.new(getApp(), "courier", 32, FONTWEIGHT_BOLD)
      @fontdecorative = FXFont.new(getApp(), "Decorative", 24, FONTWEIGHT_BOLD)

      @krex = loadIcon('icons','kres')
      @exit_button = FXButton.new(full_screen_main,nil,@krex, :opts => LAYOUT_RIGHT|LAYOUT_FIX_WIDTH, :width => 20)
      @main_frames = FXHorizontalFrame.new(full_screen_main, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT, :height => 580)
      @screens = []
      @score_frame = FXHorizontalFrame.new(full_screen_main, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :height => 0, :width => 800)
      
      @score_frame.height = 0 
      def make_screen(i)
        i.times do 
          @screens << FXVerticalFrame.new(@main_frames, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH, :width => 0)
        end
      end
      make_screen(14)
      
      @score, @scoret = 0, 0
      
      def change_screen(s)
        @screens.each do |i|
          i.width = 0
        end
        @screens[s].width = 1050
        if s !=0
          @score_frame.height = 32 
        end
      end
      change_screen(0)       
      
      def sound_play(f,path)
        right_waw = File.expand_path("../data/#{path}/#{f}.wav", __FILE__)
        Sound.play(right_waw, Sound::ASYNC)
      end

      def sound_right
        waw0 = File.expand_path("../data/audio/right.wav", __FILE__)
        right_waw = waw0
        Sound.play(right_waw, Sound::ASYNC)
      end

      def sounds_right
        right_waw = []
        16.times do |x=0|
        right_waw << File.expand_path("../data/audio/right/#{x}.wav", __FILE__)
        x+=1
        end
        rand0 = Random.new
        Sound.play(right_waw[rand0.rand(0..15)], Sound::ASYNC)
      end

      def sounds_wrong
        right_waw = []
        16.times do |x=0|
        right_waw << File.expand_path("../data/audio/wrong/#{x}.wav", __FILE__)
        x+=1
        end
        Sound.play(right_waw[rand(0..15)], Sound::ASYNC)
      end

      def sound_wrong
        waw0 = File.expand_path("../data/audio/wrong.wav", __FILE__)
        right_waw = waw0
        Sound.play(right_waw, Sound::ASYNC)
      end

      def sound_next
        right_waw = File.expand_path("../data/audio/next.wav", __FILE__)
        Sound.play(right_waw, Sound::ASYNC)
      end

      def add_icons(arr,path,count,row=1)
        if row == 2
          arr << Array.new
          count.times do |z = 0|
          arr[-1] << loadIcon(path,z.to_s)
          z+=1
          end
        else 
          count.times do |z = 0|
          arr << loadIcon(path,z.to_s)
          z+=1
          end
        end
      end
      def add_icons_from(arr,path,count,from,row = 1)
        case row 
        when 2
          arr << Array.new
          z = from 
          count.times do 
          arr[-1] << loadIcon(path,z.to_s)
          z+=1
          end
        when 1
          z = from 
          count.times do 
          arr << loadIcon(path,z.to_s)
          z+=1
          end
        end
      end
      def add_frames(arr,count,type,frame,row = 1)
        case row
          when 2
            case type
              when :v
                arr << Array.new
                count.times do
                arr[-1] << FXVerticalFrame.new(frame, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
                end
              when :h 
                arr << Array.new
                count.times do
                arr[-1] << FXHorizontalFrame.new(frame, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
                end
            end
          when 1
            case type
              when :v
                count.times do
                arr << FXVerticalFrame.new(frame, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
                end
              when :h 
                count.times do
                arr << FXHorizontalFrame.new(frame, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
                end
            end
        end
      end

      def add_buttons(array,count,frame,row = 1)
        case row
          when 1
            count.times do 
              array << FXButton.new(frame, nil, nil, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
            end
          when 2
            array << Array.new
            count.times do
              array[-1] << FXButton.new(frame, nil, nil, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
            end
        end
      end

      def scores(frame,arr)
        frame.layoutHints = LAYOUT_FILL_X
        arr << FXButton.new(frame,"Учень:#{@score}",nil, :opts => LAYOUT_LEFT)
        arr[0].font = @fontdecorative
        arr << FXButton.new(frame,"Вчитель:#{@scoret}",nil, :opts => LAYOUT_RIGHT)
        arr[1].font = @fontdecorative
      end
      def change_score(arr,who)
        case who
          when :t
            @scoret += 1
            arr[1].text = "Вчитель:#{@scoret}"
          when :s
            @score += 1
            arr[0].text = "Учень:#{@score}"
        end
      end
      def change_end_score
            @score_end[1].text = "Вчитель:#{@scoret}"
            @score_end[0].text = "Учень:#{@score}"
      end
      def add_navigate(frame,arr,var = 2)
        case var 
         when 1
          arr << FXButton.new(frame,nil,@back_ico, :opts => FRAME_GROOVE|LAYOUT_CENTER_X)
          arr << FXButton.new(frame,nil,@fvd_ico, :opts => FRAME_GROOVE|LAYOUT_CENTER_X)
         when 2
          frame.layoutHints = LAYOUT_FILL_X
          arr[0],arr[1] = nil,nil
          arr << FXVerticalFrame.new(frame, :opts => LAYOUT_RIGHT|LAYOUT_FIX_HEIGHT, :height => 20)
          arr << FXHorizontalFrame.new(frame, :opts => LAYOUT_RIGHT|LAYOUT_FIX_WIDTH, :width => 50)
          arr[0] = FXButton.new(arr[3],nil,@back_ico, :opts => FRAME_GROOVE|LAYOUT_CENTER_X)
          arr[1] = FXButton.new(arr[3],nil,@fvd_ico, :opts => FRAME_GROOVE|LAYOUT_CENTER_X)
         end
      end
      @score_global = []
      @score_global << FXButton.new(@score_frame,"Учень:#{@score}",nil, :opts => LAYOUT_LEFT|LAYOUT_CENTER_Y)
      @score_global[0].font = @fontdecorative
      @score_global << FXButton.new(@score_frame,"Вчитель:#{@scoret}",nil, :opts => LAYOUT_RIGHT|LAYOUT_CENTER_Y)
      @score_global[1].font = @fontdecorative
      @clear_button = FXButton.new(full_screen_main,nil,loadIcon('icons','clear'), :opts => LAYOUT_LEFT|LAYOUT_SIDE_TOP|LAYOUT_FIX_WIDTH, :width => 20).connect(SEL_COMMAND) do
        @score = 0; @scoret = 0
        @score_global[0].text = "Учень:#{@score}"
        @score_global[1].text = "Вчитель:#{@scoret}"
      end

############################################ icons #############################################
  @sound_ico = loadIcon('icons','sound')
  @next_ico = loadIcon('icons','next')
  @back_ico_big = loadIcon('icons','back0')
  @next_ico_big = loadIcon('icons','next0')
  @back_ico = loadIcon('icons','back')
  @fvd_ico = loadIcon('icons','forvard')
  @null200_ico = loadIcon('icons','null200')
  @null150_ico = loadIcon('icons','null150')
  @null160_ico = loadIcon('icons','160nil')
  @thems_arr = ["Дає","Бере","П'є","Їсть","Несе","Ріже"]
  @end_ico = loadIcon('icons','end')
  @nil102 = loadIcon('icons','102nil')
  @right_ico = loadIcon('icons','true')
  @wrong_ico = loadIcon('icons','false')
  @speed_icons = loadIcon('icons','speed0'),loadIcon('icons','speed1'),loadIcon('icons','speed2')
  @accepts = loadIcon('icons','accept0'),loadIcon('icons','accept1')
  @declines = loadIcon('icons','decline0'),loadIcon('icons','decline1')
######################################### First Screen #########################################
  @menu_frames = [];add_frames(@menu_frames,7,:h,@screens[0],2)
  @menu_frames[0].each_with_index do |e,i|
  e.layoutHints =LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
  e.height = 84
  end
  @buttons_menu = []
  @buttons_menu << FXButton.new(@menu_frames[0][0], nil, loadIcon("icons/menu","0"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
  @buttons_menu << FXButton.new(@menu_frames[0][1], nil, loadIcon("icons/menu","1"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(1) end
  @buttons_menu << FXButton.new(@menu_frames[0][1], nil, loadIcon("icons/menu","2"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(2) end
  @buttons_menu << FXButton.new(@menu_frames[0][1], nil, loadIcon("icons/menu","3"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(3) end
  @buttons_menu << FXButton.new(@menu_frames[0][2], nil, loadIcon("icons/menu","4"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(4) end
  @buttons_menu << FXButton.new(@menu_frames[0][2], nil, loadIcon("icons/menu","5"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(5) end
  @buttons_menu << FXButton.new(@menu_frames[0][2], nil, loadIcon("icons/menu","6"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(6) end
  @buttons_menu << FXButton.new(@menu_frames[0][3], nil, loadIcon("icons/menu","7"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(7) end
  @buttons_menu << FXButton.new(@menu_frames[0][3], nil, loadIcon("icons/menu","8"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(8) end
  @buttons_menu << FXButton.new(@menu_frames[0][3], nil, loadIcon("icons/menu","9"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(9) end
  @buttons_menu << FXButton.new(@menu_frames[0][4], nil, loadIcon("icons/menu","10"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(10) end
  @buttons_menu << FXButton.new(@menu_frames[0][4], nil, loadIcon("icons/menu","11"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(11) end
  @buttons_menu << FXButton.new(@menu_frames[0][4], nil, loadIcon("icons/menu","12"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do change_screen(12) end
  @buttons_menu << FXButton.new(@menu_frames[0][5], nil, loadIcon("icons/menu","13"), :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do getApp().exit end
    @buttons_menu <<   FXLabel.new(@menu_frames[0][6],"Cтудія логопедичних комп'ютерних ігор *Логопедійка*. Автори: Любов Чулак та Віталій Чулак")  

########################################## 1 Screen ############################################
  @s1_screen = []; add_frames(@s1_screen,5,:v,@screens[1])
    def s1_change_screen(i)
      @s1_screen.each do |z|
        z.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_X|LAYOUT_CENTER_Y|LAYOUT_FIX_HEIGHT
         z.width = 0
         z.height = 0
        @s1_screen[i].width = 1000
        @s1_screen[i].height = 550
      end
    end
    s1_change_screen(0)
    @s1_game = 0
    @s1_screens = 0
    @s1_count = 0
    def s1_screen_change(game,screen)
      case
      when screen == -1 || screen > @s1_icons[@s1_game].length-1
        s1_change_screen(0)
          @s1_game = 0
          @s1_screens = 0
          @s1_count = 0
      else
        @s1_buttons.each {|e| e.icon = nil}
        @s1_icons[game][screen].each_with_index {|e,i| @s1_buttons[i].icon = e}
        @s1_game = game
        @s1_screens = screen
        @s1_count = 0
      end
    end
    @s1_frames_0 = []; add_frames(@s1_frames_0,1,:h,@s1_screen[0])
      @s1_menu_icons = []; add_icons(@s1_menu_icons,'games/1',3)  
      @s1_menu_buttons = []; add_buttons(@s1_menu_buttons,3,@s1_frames_0[0])  
        @s1_menu_buttons.each_with_index do |e,i| 
          e.icon = @s1_menu_icons[i]
          e.connect(SEL_COMMAND) do 
            s1_change_screen(1)
            s1_screen_change(i,0)
          end
        end
    ###################################################################
      @s1_frames_1 = []; add_frames(@s1_frames_1,3,:h,@s1_screen[1])
        @s1_navigate_0 = [];add_navigate(@s1_frames_1[0],@s1_navigate_0)
        @s1_f1_v0 = []; add_frames(@s1_f1_v0,2,:v,@s1_frames_1[1])
          @s1_f1_h0 = []; add_frames(@s1_f1_h0,3,:h,@s1_f1_v0[0])
        @s1_actions = []; add_buttons(@s1_actions,2,@s1_frames_1[2])
          @s1_actions[0].icon = @right_ico
          @s1_actions[1].icon = @wrong_ico
        @s1_buttons = []
        add_buttons(@s1_buttons,4,@s1_f1_h0[0])
        add_buttons(@s1_buttons,4,@s1_f1_h0[1])
        add_buttons(@s1_buttons,4,@s1_f1_h0[2])
        @s1_sound = FXButton.new(@s1_f1_v0[1], nil, @sound_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s1_check = FXCheckButton.new(@s1_f1_v0[1], "Ознайомлення", nil, 0, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
        @s1_icons = [],[],[]
          add_icons(@s1_icons[0],"games/1/icons/0/0",6,2)
          add_icons(@s1_icons[0],"games/1/icons/0/1",12,2)

          add_icons(@s1_icons[1],"games/1/icons/1/0",6,2)
          
          add_icons(@s1_icons[2],"games/1/icons/2/0",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/1",12,2)
          add_icons(@s1_icons[2],"games/1/icons/2/2",12,2)
          add_icons(@s1_icons[2],"games/1/icons/2/3",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/4",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/5",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/6",12,2)
          add_icons(@s1_icons[2],"games/1/icons/2/7",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/8",6,2)
          add_icons(@s1_icons[2],"games/1/icons/2/9",6,2)

        @s1_navigate_0[0].connect(SEL_COMMAND) do 
            s1_screen_change(@s1_game,@s1_screens-1)
        end
        @s1_navigate_0[1].connect(SEL_COMMAND) do 
            s1_screen_change(@s1_game,@s1_screens+1)
        end
        @s1_sound.connect(SEL_COMMAND) do 
          sound_play("#{@s1_count}","games/1/audio/#{@s1_game}/#{@s1_screens}")
        end
        @s1_buttons.each_with_index do |e,i|
          e.connect(SEL_COMMAND) do 
            case @s1_check.checked?
            when true
              sound_play("#{i}","games/1/audio/#{@s1_game}/#{@s1_screens}")
            when false 
                if  i == @s1_count
                  change_score(@score_global,:s)
                  sound_right
                  e.icon = @nil102
                  @s1_count +=1
                  if @s1_count > @s1_icons[@s1_game][@s1_screens].length-1
                    s1_screen_change(@s1_game,@s1_screens+1)
                  end
                else 
                  change_score(@score_global,:t)
                  sound_wrong
                end
            end
          end
        end
        @s1_actions.each_with_index do |e,i|
         e.connect(SEL_COMMAND) do 
          if i == 0 
             change_score(@score_global,:s)
             sound_right
          end
          if i == 1 
            change_score(@score_global,:t)
            sound_wrong
          end
          @s1_buttons[@s1_count].icon = @nil102
          @s1_count +=1
            if @s1_count > @s1_icons[@s1_game][@s1_screens].length-1
              s1_screen_change(@s1_game,@s1_screens+1)
            end
          end
        end
########################################## 2 Screen ############################################
  @s2_frames = []; add_frames(@s2_frames, 5, :h, @screens[2])
    @s2_frames.each {|i| i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X}
    
    def s2_end_game(z=1)
      if z == 1
      @s2_frames.each do |i| 
        i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
        i.height = 0
      end
      @s2_frames[4].height = 100
      else
        @s2_frames.each do |i| 
          i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
        end
        @s2_frames[4].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
        @s2_frames[4].height = 0
      end
    end
    s2_end_game(2)
    @s2_navigate = []; add_navigate(@s2_frames[0],@s2_navigate)
    @s2_top_icons = []
        6.times do |x = 0|
            add_icons(@s2_top_icons,"games/2/icons/0/#{x}/",4,2)
            x+=1
        end
    @s2_screen = 0
    @s2_num = 0

    @s2_top_buttons = []; add_buttons(@s2_top_buttons,4,@s2_frames[1])   
      @s2_top_buttons.each_with_index do |e,i|
        e.connect(SEL_COMMAND) do 
          sound_play("#{i}","games/2/audio/#{@s2_screen}")
        end
      end  
    
      @s2_icons = []
      6.times do |x = 0|
          add_icons_from(@s2_icons,"games/2/icons/0/#{x}/",1,4)
          x+=1
      end
      @s2_button = FXButton.new(@s2_frames[3], nil, @s2_icons[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      @s2_button.connect(SEL_COMMAND) {sound_play("#{4}","games/2/audio/#{@s2_screen}")}
      @s2_end_button = FXButton.new(@s2_frames[4], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      @s2_end_button.connect(SEL_COMMAND)do
        s2_end_game(2)
        @s2_screen = 0
        @s2_num = 0
        s2_change_screen
        s2_double_change(0,0)
        change_screen(0)
      end

    @s2_double_frame = []; add_frames(@s2_double_frame,4, :h, @s2_frames[2])
        @s2_double_frame.each do |i| 
          i.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
          i.width = 205
        end
      @s2_double_buttons = []; @s2_double_frame.each {|i| add_buttons(@s2_double_buttons, 4, i, 2)}
        @s2_double_icons = []; add_icons(@s2_double_icons,'games/2',4)
        def s2_double_change(who,num)
          case num 
            when 0 
              4.times do |x|
                @s2_double_buttons[x].each {|i| i.width = 0}
                @s2_double_buttons[x][0].width = 50
                @s2_double_buttons[x][1].width = 50
                x+=1
              end
            when :t
              @s2_double_buttons[who].each {|i| i.width = 0}
              @s2_double_buttons[who][2].width = 50
            when :f
              @s2_double_buttons[who].each {|i| i.width = 0}
              @s2_double_buttons[who][3].width = 50
          end
        end   
        def s2_change_screen
          if @s2_screen != (@s2_top_icons.length)
            @s2_top_buttons.each_with_index do |e,i|
              e.icon = @s2_top_icons[@s2_screen][i]
              s2_double_change(0,0)
            end
          @s2_num = 0
          @s2_button.icon = @s2_icons[@s2_screen]
          else 
            s2_end_game
          end
        end
        s2_change_screen
        @s2_double_buttons.each_with_index do |arr, z|
          arr.each_with_index do |e, i|
            e.icon = @s2_double_icons[i]
            e.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
            e.connect(SEL_COMMAND) do 
              case i 
              when 0 
                sound_right
                change_score(@score_global,:s)
                s2_double_change(z,:t)
                @s2_num +=1
              when 1 
                sound_wrong
                change_score(@score_global,:t)
                s2_double_change(z,:f)
                @s2_num +=1
              end
              if @s2_num == 4
                @s2_screen +=1
                s2_change_screen
              end
            end
          end
          s2_double_change(z,0)
        end
        @s2_navigate[0].connect(SEL_COMMAND) do 
          if @s2_screen != 0
            @s2_screen -=1
            s2_change_screen
          end
        end
        
        @s2_navigate[1].connect(SEL_COMMAND) do 
          @s2_screen +=1
          s2_change_screen
        end

########################################## 3 Screen ############################################

  @s3_frames = []; add_frames(@s3_frames, 5, :h, @screens[3])
  @s3_frames.each {|i| i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X}

  def s3_end_game(z=1)
    if z == 1
    @s3_frames.each do |i| 
      i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
      i.height = 0
    end
    @s3_frames[4].height = 100
    else
      @s3_frames.each do |i| 
        i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
      end
      @s3_frames[4].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
      @s3_frames[4].height = 0
    end
  end
  s3_end_game(2)
  @s3_navigate = []; add_navigate(@s3_frames[0],@s3_navigate)
  @s3_top_icons = []
      6.times do |x = 0|
          add_icons(@s3_top_icons,"games/3/icons/#{x}/",4,2)
          x+=1
      end
  @s3_screen = 0
  @s3_num = 0

  @s3_top_buttons = []; add_buttons(@s3_top_buttons,4,@s3_frames[1])   
    @s3_top_buttons.each_with_index do |e,i|
      e.connect(SEL_COMMAND) do 
        sound_play("#{i}","games/3/audio/#{@s3_screen}")
      end
    end  

    @s3_icons = []
    6.times do |x = 0|
        add_icons_from(@s3_icons,"games/3/icons/#{x}/",1,4)
        x+=1
    end
    @s3_button = FXButton.new(@s3_frames[3], nil, @s3_icons[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s3_button.connect(SEL_COMMAND) {sound_play("#{4}","games/3/audio/#{@s3_screen}")}
    @s3_end_button = FXButton.new(@s3_frames[4], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s3_end_button.connect(SEL_COMMAND)do
      s3_end_game(2)
      @s3_screen = 0
      @s3_num = 0
      s3_change_screen
      s3_double_change(0,0)
      change_screen(0)
    end

  @s3_double_frame = []; add_frames(@s3_double_frame,4, :h, @s3_frames[2])
      @s3_double_frame.each do |i| 
        i.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
        i.width = 205
      end
    @s3_double_buttons = []; @s3_double_frame.each {|i| add_buttons(@s3_double_buttons, 4, i, 2)}
      @s3_double_icons = []; add_icons(@s3_double_icons,'games/2',4)
      def s3_double_change(who,num)
        case num 
          when 0 
            4.times do |x|
              @s3_double_buttons[x].each {|i| i.width = 0}
              @s3_double_buttons[x][0].width = 50
              @s3_double_buttons[x][1].width = 50
              x+=1
            end
          when :t
            @s3_double_buttons[who].each {|i| i.width = 0}
            @s3_double_buttons[who][2].width = 50
          when :f
            @s3_double_buttons[who].each {|i| i.width = 0}
            @s3_double_buttons[who][3].width = 50
        end
      end   
      def s3_change_screen
        if @s3_screen != (@s3_top_icons.length)
          @s3_top_buttons.each_with_index do |e,i|
            e.icon = @s3_top_icons[@s3_screen][i]
            s3_double_change(0,0)
          end
        @s3_num = 0
        @s3_button.icon = @s3_icons[@s3_screen]
        else 
          s3_end_game
        end
      end
      s3_change_screen
      @s3_double_buttons.each_with_index do |arr, z|
        arr.each_with_index do |e, i|
          e.icon = @s3_double_icons[i]
          e.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
          e.connect(SEL_COMMAND) do 
            case i 
            when 0 
              sound_right
              change_score(@score_global,:s)
              s3_double_change(z,:t)
              @s3_num +=1
            when 1 
              sound_wrong
              change_score(@score_global,:t)
              s3_double_change(z,:f)
              @s3_num +=1
            end
            if @s3_num == 4
              @s3_screen +=1
              s3_change_screen
            end
          end
        end
        s3_double_change(z,0)
      end
      @s3_navigate[0].connect(SEL_COMMAND) do 
        if @s3_screen != 0
          @s3_screen -=1
          s3_change_screen
        end
      end
      
      @s3_navigate[1].connect(SEL_COMMAND) do 
        @s3_screen +=1
        s3_change_screen
      end

########################################## 4 Screen ############################################


      @s4_frames = []; add_frames(@s4_frames, 5, :h, @screens[4])
      @s4_frames.each {|i| i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X}

      def s4_end_game(z=1)
        if z == 1
          @s4_frames.each do |i| 
            i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
            i.height = 0
          end
          @s4_frames[4].height = 100
        else
          @s4_frames.each do |i| 
            i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
          end
          @s4_frames[4].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          @s4_frames[4].height = 0
        end
      end
      s4_end_game(2)
      @s4_navigate = []; add_navigate(@s4_frames[0],@s4_navigate)
      @s4_top_icons = []
          8.times do |x = 0|
              add_icons(@s4_top_icons,"games/4/icons/#{x}/",4,2)
              x+=1
          end
      @s4_screen = 0
      @s4_num = 0

      @s4_top_buttons = []; add_buttons(@s4_top_buttons,4,@s4_frames[1])   
        @s4_top_buttons.each_with_index do |e,i|
          e.connect(SEL_COMMAND) do 
            sound_play("#{i}","games/4/audio/#{@s4_screen}/1")
          end
        end  

        @s4_icons = []
        8.times do |x = 0|
            add_icons(@s4_icons,"games/4/icons/#{x}/0/",4,2)
            x+=1
        end
        @s4_buttons = [];add_buttons(@s4_buttons,4,@s4_frames[3])
          @s4_buttons.each_with_index do |e,i|
          e.connect(SEL_COMMAND) {sound_play("#{i}","games/4/audio/#{@s4_screen}/0")}
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
          e.width = 202
        end
        @s4_end_button = FXButton.new(@s4_frames[4], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s4_end_button.connect(SEL_COMMAND)do
          s4_end_game(2)
          @s4_screen = 0
          @s4_num = 0
          s4_change_screen
          s4_double_change(0,0)
          change_screen(0)
        end

      @s4_double_frame = []; add_frames(@s4_double_frame,4, :h, @s4_frames[2])
          @s4_double_frame.each do |i| 
            i.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
            i.width = 205
          end
        @s4_double_buttons = []; @s4_double_frame.each {|i| add_buttons(@s4_double_buttons, 4, i, 2)}
          @s4_double_icons = []; add_icons(@s4_double_icons,'games/2',4)
          def s4_double_change(who,num)
            case num 
              when 0 
                4.times do |x|
                  @s4_double_buttons[x].each {|i| i.width = 0}
                  @s4_double_buttons[x][0].width = 50
                  @s4_double_buttons[x][1].width = 50
                  
                  @s4_double_frame[2].width = 205
                  @s4_double_frame[3].width = 205
                  @s4_buttons[2].width = 202
                  @s4_buttons[3].width = 202
                  x+=1
                end
                if @s4_screen == 6 || @s4_screen == 7
                    @s4_double_frame[2].width = 0
                    @s4_double_frame[3].width = 0
                    @s4_buttons[2].width = 0
                    @s4_buttons[3].width = 0

                end
              when :t
                @s4_double_buttons[who].each {|i| i.width = 0}
                @s4_double_buttons[who][2].width = 50
              when :f
                @s4_double_buttons[who].each {|i| i.width = 0}
                @s4_double_buttons[who][3].width = 50
            end
          end   
          def s4_change_screen
            if @s4_screen != (@s4_top_icons.length)
              @s4_top_buttons.each_with_index do |e,i|
                e.icon = @s4_top_icons[@s4_screen][i]
                s4_double_change(0,0)
              end
            @s4_num = 0
            @s4_buttons.each_with_index do |z,x|
              z.icon = @s4_icons[@s4_screen][x]
            end
            else 
              s4_end_game
            end
          end
          s4_change_screen
          @s4_double_buttons.each_with_index do |arr, z|
            arr.each_with_index do |e, i|
              e.icon = @s4_double_icons[i]
              e.layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_Y|LAYOUT_CENTER_X
              e.connect(SEL_COMMAND) do 
                case i 
                when 0 
                  sound_right
                  change_score(@score_global,:s)
                  s4_double_change(z,:t)
                  
                  if @s4_screen == 6 || @s4_screen == 7 
                    @s4_num += 2
                  else
                   @s4_num +=1
                  end
                when 1 
                  sound_wrong
                  change_score(@score_global,:t)
                  s4_double_change(z,:f)
                  if @s4_screen == 6 || @s4_screen == 7
                    @s4_num += 2
                  else
                   @s4_num +=1
                  end
                end
                if @s4_num == 4
                  @s4_screen +=1
                  s4_change_screen
                end
              end
            end
            s4_double_change(z,0)
          end
          @s4_navigate[0].connect(SEL_COMMAND) do 
            if @s4_screen != 0
              @s4_screen -=1
              s4_change_screen
            end
          end
          
          @s4_navigate[1].connect(SEL_COMMAND) do 
            @s4_screen +=1
            s4_change_screen
          end

########################################## 5 Screen ############################################
  @s5_frames = []; add_frames(@s5_frames, 3, :h, @screens[5])
  @s5_navigate = []; add_navigate(@s5_frames[0],@s5_navigate)
  @s5_pair_frames = []; add_frames(@s5_pair_frames, 3, :v, @s5_frames[1])
    @s5_left_frames = []; add_frames(@s5_left_frames, 3, :h, @s5_pair_frames[0])
      @s5_left_buttons = [] 
        add_buttons(@s5_left_buttons,3,@s5_left_frames[0])
        add_buttons(@s5_left_buttons,3,@s5_left_frames[1])
        add_buttons(@s5_left_buttons,3,@s5_left_frames[2])
        @s5_left_icons = []; 10.times do |x=0|
          add_icons(@s5_left_icons,"games/5/#{x}/0",9,2)
          x+=1
        end
    @s5_right_frames = []; add_frames(@s5_right_frames, 3, :h, @s5_pair_frames[2])
      @s5_right_buttons = [] 
        add_buttons(@s5_right_buttons,3,@s5_right_frames[0])
        add_buttons(@s5_right_buttons,3,@s5_right_frames[1])
        add_buttons(@s5_right_buttons,3,@s5_right_frames[2])
        @s5_right_icons = []; 10.times do |x=0|
          add_icons(@s5_right_icons,"games/5/#{x}/1",9,2)
          x+=1
        end
    @s5_pair_frames[1].layoutHints = LAYOUT_CENTER_X|LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH
    @s5_pair_frames[1].width = 50
      @s5_end_button = FXButton.new(@s5_pair_frames[1], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH, :width => 0)
      @s5_end_button.width = 0
      

    @s5_screen = 0
    @s5_count = 0
    def s5_change_screen
      case @s5_screen
      when 10
        @s5_left_buttons.each {|i| i.icon = nil}
        @s5_right_buttons.each {|i| i.icon = nil}
        @s5_pair_frames[1].width = 600
        @s5_end_button.width = 500
      else 
        @s5_left_count = 0
        @s5_right_count = 0
        @s5_count = 0
        @s5_pair_frames[1].width = 50
        @s5_end_button.width = 0
        s5_shuffle_left = @s5_left_icons[@s5_screen].dup.shuffle!
        s5_shuffle_right = @s5_right_icons[@s5_screen].dup.shuffle!
        @s5_left_buttons.each_with_index {|e,i| e.icon = s5_shuffle_left[i]}  
        @s5_right_buttons.each_with_index {|e,i| e.icon = s5_shuffle_right[i]}
      end
    end
    s5_change_screen
    @s5_navigate[0].connect(SEL_COMMAND) do
      if @s5_screen != 0
        @s5_screen -= 1
        s5_change_screen
      end
    end  
    @s5_navigate[1].connect(SEL_COMMAND) do
      if @s5_screen != 10
        @s5_screen += 1
        s5_change_screen
      end
    end
    @s5_left_buttons.each_with_index do |e,i|
      e.connect(SEL_COMMAND) do 
        if @s5_left_count != 1
          if e.icon == @s5_left_icons[@s5_screen][0]
            sounds_right
            change_score(@score_global,:s)
            @s5_count +=1
            @s5_left_count = 1
            if @s5_count == 2 
              @s5_count = 0
              @s5_screen +=1
              s5_change_screen
            end
          else 
            sounds_wrong
            change_score(@score_global,:t)
          end
        end
      end
    end
    @s5_right_buttons.each_with_index do |e,i|
      e.connect(SEL_COMMAND) do 
        if @s5_right_count != 1
          if e.icon == @s5_right_icons[@s5_screen][0]
            sounds_right
            change_score(@score_global,:s)
            @s5_count +=1
            @s5_right_count = 1
            if @s5_count == 2 
              @s5_count = 0
              @s5_screen +=1
              s5_change_screen
            end
          else 
            sounds_wrong
            change_score(@score_global,:t)
          end
        end
      end
    end
    @s5_end_button.connect(SEL_COMMAND) do 
      @s5_screen = 0
      s5_change_screen
      change_screen(0)
    end
########################################## 6 Screen ############################################

      @s6_frames = []; add_frames(@s6_frames, 5, :h, @screens[6])
      @s6_frames.each {|i| i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X}

      def s6_end_game(z=1)
        if z == 1
        @s6_frames.each do |i| 
          i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          i.height = 0
        end
        @s6_frames[4].height = 100
        else
          @s6_frames.each do |i| 
            i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
          end
          @s6_frames[4].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          @s6_frames[4].height = 0
        end
      end
      s6_end_game(2)
      @s6_navigate = []; add_navigate(@s6_frames[0],@s6_navigate)
      @s6_top_icons = []
          12.times do |x = 0|
              add_icons_from(@s6_top_icons,"games/6/icons/#{x}/",4,1,2)
              x+=1
          end
      @s6_screen = 0
      @s6_num = 0

      @s6_top_buttons = []; 
        add_buttons(@s6_top_buttons,4,@s6_frames[1])
        
        @s6_top_buttons.each_with_index do |e,i|
          e.connect(SEL_COMMAND) do 
            @s6_top_icons[@s6_screen].each_with_index do |ee, ii|
              if e.icon == ee
                sound_play("#{ii+=1}","games/6/audio/#{@s6_screen}")
              end
            end
              if e.icon == @s6_top_icons[@s6_screen][0]
                change_score(@score_global,:s)
                @s6_screen +=1
                s6_change_screen
              else 
                change_score(@score_global,:t)
              end
          end
        end  

        @s6_icons = []
        12.times do |x = 0|
            add_icons(@s6_icons,"games/6/icons/#{x}/",1)
            x+=1
        end
        @s6_button = FXButton.new(@s6_frames[3], nil, @s6_icons[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s6_button.connect(SEL_COMMAND) {sound_play("#{0}","games/6/audio/#{@s6_screen}")}
        @s6_end_button = FXButton.new(@s6_frames[4], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s6_end_button.connect(SEL_COMMAND)do
          s6_end_game(2)
          @s6_screen = 0
          @s6_num = 0
          s6_change_screen
          change_screen(0)
        end

          def s6_change_screen
            if @s6_screen != (@s6_top_icons.length)
              s6_shuffle = @s6_top_icons[@s6_screen].dup
              s6_shuffle.shuffle!
              @s6_top_buttons.each_with_index do |e,i|
                e.icon = s6_shuffle[i]
              end
            @s6_num = 0
            @s6_button.icon = @s6_icons[@s6_screen]
            else 
              s6_end_game
            end
          end
          s6_change_screen
          
          @s6_navigate[0].connect(SEL_COMMAND) do 
            if @s6_screen != 0
              @s6_screen -=1
              s6_change_screen
            end
          end
          
          @s6_navigate[1].connect(SEL_COMMAND) do 
            @s6_screen +=1
            s6_change_screen
          end

########################################## 7 Screen ############################################
      @s7_frames = []; add_frames(@s7_frames, 5, :h, @screens[7])
      @s7_frames.each {|i| i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X}

      def s7_end_game(z=1)
        if z == 1
        @s7_frames.each do |i| 
          i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          i.height = 0
        end
        @s7_frames[4].height = 100
        else
          @s7_frames.each do |i| 
            i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
          end
          @s7_frames[4].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          @s7_frames[4].height = 0
        end
      end
      s7_end_game(2)
      @s7_navigate = []; add_navigate(@s7_frames[0],@s7_navigate)
      @s7_top_icons = []
          3.times do |x = 0|
              add_icons(@s7_top_icons,"games/7/icons/#{x}/",8,2)
              x+=1
          end
      @s7_screen = 0
      @s7_num = 0

      @s7_top_buttons = []; 
        add_buttons(@s7_top_buttons,4,@s7_frames[1])
        add_buttons(@s7_top_buttons,4,@s7_frames[2])  
        
        @s7_top_buttons.each_with_index do |e,i|
          e.connect(SEL_COMMAND) do 
              if e.icon == @s7_top_icons[@s7_screen][0] || e.icon == @s7_top_icons[@s7_screen][1] ||
                 e.icon == @s7_top_icons[@s7_screen][2] || e.icon == @s7_top_icons[@s7_screen][3]
                change_score(@score_global,:s)
                sounds_right
                e.icon = @null160_ico
                @s7_num +=1
                if @s7_num == 4
                  @s7_screen +=1
                  s7_change_screen
                  @s7_num = 0
                end 
              else 
                change_score(@score_global,:t)
                sounds_wrong
              end
          end
        end  

        @s7_icons = []
        3.times do |x = 0|
            add_icons_from(@s7_icons,"games/7/icons/#{x}/",1,8)
            x+=1
        end
        @s7_button = FXButton.new(@s7_frames[3], nil, @s7_icons[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s7_button.connect(SEL_COMMAND) {sound_play("#{0}","games/7/audio/#{@s7_screen}")}
        @s7_end_button = FXButton.new(@s7_frames[4], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
        @s7_end_button.connect(SEL_COMMAND)do
          s7_end_game(2)
          @s7_screen = 0
          @s7_num = 0
          s7_change_screen
          change_screen(0)
        end

          def s7_change_screen
            if @s7_screen != (@s7_top_icons.length)
              s7_shuffle = @s7_top_icons[@s7_screen].dup
              s7_shuffle.shuffle!
              @s7_top_buttons.each_with_index do |e,i|
                e.icon = s7_shuffle[i]
              end
            @s7_num = 0
            @s7_button.icon = @s7_icons[@s7_screen]
            else 
              s7_end_game
            end
          end
          s7_change_screen
          
          @s7_navigate[0].connect(SEL_COMMAND) do 
            if @s7_screen != 0
              @s7_screen -=1
              s7_change_screen
            end
          end
          
          @s7_navigate[1].connect(SEL_COMMAND) do 
            @s7_screen +=1
            s7_change_screen
          end
########################################## 8 Screen ############################################
  @s8_frames = []; add_frames(@s8_frames, 1, :v, @screens[8])
  @s8_help_frame = []; add_frames(@s8_help_frame,2, :h, @s8_frames[0])
  @s8_navigate = []; add_navigate(@s8_help_frame[0],@s8_navigate)
    @s8_frames_0 = []; add_frames(@s8_frames_0, 4, :v, @s8_help_frame[1])
      @s8_icons = []; 10.times do |x|
        add_icons(@s8_icons,"games/8/icons/#{x}",1)
      end
      @s8_image = FXButton.new(@s8_frames_0[0], nil, @s8_icons[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s8_screen = 0
    @s8_temp = 0
    @s8_count = 0
    @s8_frames_speed = []; add_frames(@s8_frames_speed,4,:h, @s8_frames_0[1])
      @s8_speed = []
          add_buttons(@s8_speed,1,@s8_frames_speed[0])
          add_buttons(@s8_speed,1,@s8_frames_speed[1])
          add_buttons(@s8_speed,1,@s8_frames_speed[2])
          @s8_speed.each_with_index do |e,i|
            e.icon = @speed_icons[i]
            e.connect(SEL_COMMAND) do 
              sound_play(i.to_s,"games/8/audio/#{@s8_screen}")
              @s8_temp = i
            end
          end  
      @s8_accepts = []
          add_buttons(@s8_accepts,1,@s8_frames_speed[0])
          add_buttons(@s8_accepts,1,@s8_frames_speed[1])
          add_buttons(@s8_accepts,1,@s8_frames_speed[2])
      @s8_declines = []
          add_buttons(@s8_declines,1,@s8_frames_speed[0])
          add_buttons(@s8_declines,1,@s8_frames_speed[1])
          add_buttons(@s8_declines,1,@s8_frames_speed[2])
      @s8_choise = []
          add_buttons(@s8_choise,1,@s8_frames_speed[0])
          add_buttons(@s8_choise,1,@s8_frames_speed[1])
          add_buttons(@s8_choise,1,@s8_frames_speed[2])
          @s8_next = FXButton.new(@s8_frames_0[1], nil, nil, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
     @s8_end = FXButton.new(@s8_frames_0[2], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      
            @s8_accepts.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s8_choise[i].icon = @accepts[1]
                @s8_accepts[i].icon = nil
                @s8_declines[i].icon = nil
                change_score(@score_global,:s)
                @s8_count +=1
                @s8_count == 3 && @s8_next.icon = @next_ico
              end
            end  
            @s8_declines.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s8_choise[i].icon = @declines[1]
                @s8_accepts[i].icon = nil
                @s8_declines[i].icon = nil
                change_score(@score_global,:t)
                @s8_count +=1
                @s8_count == 3 && @s8_next.icon = @next_ico
              end
            end  
            @s8_image.connect(SEL_COMMAND) do 
              sound_play(2.to_s,"games/8/audio/#{@s8_screen}")
            end
        
    def s8_refresh_choise
      @s8_accepts.each {|i| i.icon = @accepts[0]}
      @s8_declines.each {|i| i.icon = @declines[0]}
      @s8_choise.each {|i| i.icon = nil}
    end
    def s8_change_screen
      case @s8_screen 
      when 10 
        @s8_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
          e.width = 0
        end
        @s8_frames_0[2].width = 600
      else 
        @s8_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
        end
        @s8_frames_0[2].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
        @s8_frames_0[2].width = 0
        @s8_image.icon = @s8_icons[@s8_screen]
        s8_refresh_choise
        @s8_next.icon = nil
        @s8_count = 0
      end
    end
    @s8_navigate[0].connect(SEL_COMMAND) do
      if @s8_screen != 0
        @s8_screen -=1
        s8_change_screen
      end 
    end
    @s8_navigate[1].connect(SEL_COMMAND) do
      if @s8_screen != 9
        @s8_screen +=1
        s8_change_screen
      end 
    end
    @s8_next.connect(SEL_COMMAND) do
      if @s8_screen != 10
        @s8_screen +=1
        s8_change_screen
      end 
    end
    s8_change_screen
    @s8_end.connect(SEL_COMMAND) do 
      change_screen(0) 
      @s8_screen = 0
      @s8_temp = 0
      @s8_count = 0
      s8_change_screen
    end
########################################## 9 Screen ############################################

  @s9_frames = []; add_frames(@s9_frames, 1, :v, @screens[9])
  @s9_help_frame = []; add_frames(@s9_help_frame,2, :h, @s9_frames[0])
  @s9_navigate = []; add_navigate(@s9_help_frame[0],@s9_navigate)
    @s9_frames_0 = []; add_frames(@s9_frames_0, 4, :v, @s9_help_frame[1])
      @s9_icons = []; 3.times do |x = 0|
        add_icons(@s9_icons,"games/9/icons/#{x}",16,2)
        x +=1
      end
      @s9_frames_icons = []; add_frames(@s9_frames_icons,4,:h, @s9_frames_0[0])
      @s9_image = []
        add_buttons(@s9_image,4,@s9_frames_icons[0])
        add_buttons(@s9_image,4,@s9_frames_icons[1])
        add_buttons(@s9_image,4,@s9_frames_icons[2])
        add_buttons(@s9_image,4,@s9_frames_icons[3])
    @s9_screen = 0
    @s9_temp = 0
    @s9_count = 0
    @s9_frames_sound = []; add_frames(@s9_frames_sound,1,:h, @s9_frames_0[1])
      @s9_sound = FXButton.new(@s9_frames_sound[0], nil, @sound_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND){sound_play('0',"games/9/audio/")}
  
      @s9_frames_speed = []; add_frames(@s9_frames_speed,4,:h, @s9_frames_0[1])
      @s9_speed = []
          add_buttons(@s9_speed,1,@s9_frames_speed[0])
          add_buttons(@s9_speed,1,@s9_frames_speed[1])
          add_buttons(@s9_speed,1,@s9_frames_speed[2])
          @s9_speed.each_with_index do |e,i|
            e.icon = @speed_icons[i]
            e.connect(SEL_COMMAND) do 
              sound_play(i.to_s,"games/9/audio/speed/#{@s9_screen}")
              @s9_temp = i
            end
          end  
      @s9_accepts = []
          add_buttons(@s9_accepts,1,@s9_frames_speed[0])
          add_buttons(@s9_accepts,1,@s9_frames_speed[1])
          add_buttons(@s9_accepts,1,@s9_frames_speed[2])
      @s9_declines = []
          add_buttons(@s9_declines,1,@s9_frames_speed[0])
          add_buttons(@s9_declines,1,@s9_frames_speed[1])
          add_buttons(@s9_declines,1,@s9_frames_speed[2])
      @s9_choise = []
          add_buttons(@s9_choise,1,@s9_frames_speed[0])
          add_buttons(@s9_choise,1,@s9_frames_speed[1])
          add_buttons(@s9_choise,1,@s9_frames_speed[2])
          @s9_next = FXButton.new(@s9_frames_0[1], nil, nil, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s9_end = FXButton.new(@s9_frames_0[2], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      
            @s9_accepts.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s9_choise[i].icon = @accepts[1]
                @s9_accepts[i].icon = nil
                @s9_declines[i].icon = nil
                change_score(@score_global,:s)
                sound_right
                @s9_count +=1
                @s9_count == 3 && @s9_next.icon = @next_ico
              end
            end  
            @s9_declines.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s9_choise[i].icon = @declines[1]
                @s9_accepts[i].icon = nil
                @s9_declines[i].icon = nil
                change_score(@score_global,:t)
                sound_wrong
                @s9_count +=1
                @s9_count == 3 && @s9_next.icon = @next_ico
              end
            end  
        
    def s9_refresh_choise
      @s9_accepts.each {|i| i.icon = @accepts[0]}
      @s9_declines.each {|i| i.icon = @declines[0]}
      @s9_choise.each {|i| i.icon = nil}
    end
    def s9_change_screen
      case @s9_screen 
      when 3 
        @s9_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
          e.width = 0
        end
        @s9_frames_0[2].width = 600
      else 
        @s9_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
        end
        @s9_frames_0[2].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
        @s9_frames_0[2].width = 0
        @s9_image.each_with_index {|e,i| e.icon = @s9_icons[@s9_screen][i]}
        s9_refresh_choise
        @s9_next.icon = nil
        @s9_count = 0
      end
    end
    @s9_navigate[0].connect(SEL_COMMAND) do
      if @s9_screen != 0
        @s9_screen -=1
        s9_change_screen
      end 
    end
    @s9_navigate[1].connect(SEL_COMMAND) do
      if @s9_screen != 2
        @s9_screen +=1
        s9_change_screen
      end 
    end
    @s9_next.connect(SEL_COMMAND) do
      if @s9_screen != 3
        @s9_screen +=1
        s9_change_screen
      end 
    end
    s9_change_screen
    @s9_end.connect(SEL_COMMAND) do 
      change_screen(0) 
      @s9_screen = 0
      @s9_temp = 0
      @s9_count = 0
      s9_change_screen
    end
######################################### 10 Screen  ###########################################

  @s10_frames = []; add_frames(@s10_frames, 1, :v, @screens[10])
  @s10_help_frame = []; add_frames(@s10_help_frame,2, :h, @s10_frames[0])
  @s10_navigate = []; add_navigate(@s10_help_frame[0],@s10_navigate)
    @s10_frames_0 = []; add_frames(@s10_frames_0, 4, :v, @s10_help_frame[1])
      @s10_icons = []; 4.times do |x = 0|
        add_icons(@s10_icons,"games/10/icons/#{x}",12,2)
        x +=1
      end
      @s10_frames_icons = []; add_frames(@s10_frames_icons,4,:h, @s10_frames_0[0])
      @s10_image = []
        add_buttons(@s10_image,4,@s10_frames_icons[0])
        add_buttons(@s10_image,4,@s10_frames_icons[1])
        add_buttons(@s10_image,4,@s10_frames_icons[2])
    @s10_screen = 0
    @s10_temp = 0
    @s10_count = 0
    @s10_imgs = []; add_icons(@s10_imgs,'games/10/icons',4)
    @s10_frames_sound = []; add_frames(@s10_frames_sound,1,:h, @s10_frames_0[1])
    @s10_sound = FXButton.new(@s10_frames_sound[0], nil, @s10_imgs[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s10_sound.connect(SEL_COMMAND){sound_play('2',"games/10/audio/#{@s10_screen}")}

      @s10_frames_speed = []; add_frames(@s10_frames_speed,4,:h, @s10_frames_0[1])
      @s10_speed = []
          add_buttons(@s10_speed,1,@s10_frames_speed[0])
          add_buttons(@s10_speed,1,@s10_frames_speed[1])
          add_buttons(@s10_speed,1,@s10_frames_speed[2])
          @s10_speed.each_with_index do |e,i|
            e.icon = @speed_icons[i]
            e.connect(SEL_COMMAND) do 
              sound_play(i.to_s,"games/10/audio/#{@s10_screen}")
              @s10_temp = i
            end
          end  
      @s10_accepts = []
          add_buttons(@s10_accepts,1,@s10_frames_speed[0])
          add_buttons(@s10_accepts,1,@s10_frames_speed[1])
          add_buttons(@s10_accepts,1,@s10_frames_speed[2])
      @s10_declines = []
          add_buttons(@s10_declines,1,@s10_frames_speed[0])
          add_buttons(@s10_declines,1,@s10_frames_speed[1])
          add_buttons(@s10_declines,1,@s10_frames_speed[2])
      @s10_choise = []
          add_buttons(@s10_choise,1,@s10_frames_speed[0])
          add_buttons(@s10_choise,1,@s10_frames_speed[1])
          add_buttons(@s10_choise,1,@s10_frames_speed[2])
          @s10_next = FXButton.new(@s10_frames_0[1], nil, nil, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @s10_end = FXButton.new(@s10_frames_0[2], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      
            @s10_accepts.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s10_choise[i].icon = @accepts[1]
                @s10_accepts[i].icon = nil
                @s10_declines[i].icon = nil
                change_score(@score_global,:s)
                sound_right
                @s10_count +=1
                @s10_count == 3 && @s10_next.icon = @next_ico
              end
            end  
            @s10_declines.each_with_index do |e, i| 
              e.connect(SEL_COMMAND)do 
                @s10_choise[i].icon = @declines[1]
                @s10_accepts[i].icon = nil
                @s10_declines[i].icon = nil
                change_score(@score_global,:t)
                sound_wrong
                @s10_count +=1
                @s10_count == 3 && @s10_next.icon = @next_ico
              end
            end  
        
    def s10_refresh_choise
      @s10_accepts.each {|i| i.icon = @accepts[0]}
      @s10_declines.each {|i| i.icon = @declines[0]}
      @s10_choise.each {|i| i.icon = nil}
    end
    def s10_change_screen
      case @s10_screen 
      when 4 
        @s10_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
          e.width = 0
        end
        @s10_frames_0[2].width = 600
      else 
        @s10_frames_0.each do |e| 
          e.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X
        end
        @s10_frames_0[2].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
        @s10_frames_0[2].width = 0
        @s10_image.each_with_index {|e,i| e.icon = @s10_icons[@s10_screen][i]}
        @s10_sound.icon = @s10_imgs[@s10_screen]
        s10_refresh_choise
        @s10_next.icon = nil
        @s10_count = 0
      end
    end
    @s10_navigate[0].connect(SEL_COMMAND) do
      if @s10_screen != 0
        @s10_screen -=1
        s10_change_screen
      end 
    end
    @s10_navigate[1].connect(SEL_COMMAND) do
      if @s10_screen != 3
        @s10_screen +=1
        s10_change_screen
      end 
    end
    @s10_next.connect(SEL_COMMAND) do
      if @s10_screen != 4
        @s10_screen +=1
        s10_change_screen
      end 
    end
    s10_change_screen
    @s10_end.connect(SEL_COMMAND) do 
      change_screen(0) 
      @s10_screen = 0
      @s10_temp = 0
      @s10_count = 0
      s10_change_screen
    end
######################################### 11 Screen  ###########################################
    @s11_main_frame = FXHorizontalFrame.new(@screens[11], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH, :width => 1000 )
    @s11_useful_frame = [];  add_frames(@s11_useful_frame, 2, :v, @s11_main_frame )  
    @s11_useful_frame[0].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
      @s11_useful_frame[0].width = 1050
    @s11_useful_frame[1].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_WIDTH
      @s11_useful_frame[1].width = 0

    @s11_h_frame0 = [];  add_frames(@s11_h_frame0, 2, :h, @s11_useful_frame[0]) 
      @s11_buttons0 = []; 
        add_buttons(@s11_buttons0,1,@s11_h_frame0[0])
        add_buttons(@s11_buttons0,1,@s11_h_frame0[1])
        @s11_buttons0[0].connect(SEL_COMMAND)do 
        sound_play(0,"games/11")
        end
        @s11_buttons0[0].icon = loadIcon('games/11','0')  
        @s11_buttons0[1].icon = @next_ico_big
        @s11_buttons0[1].connect(SEL_COMMAND)do 
          @s11_useful_frame[1].width = 1050
          @s11_useful_frame[0].width = 0
          s11_refresh_choise
          sound_right
        end
    @s11_h_frame = [];  add_frames(@s11_h_frame, 1, :h, @s11_useful_frame[1]) 
    @s11_v_frame = [];  add_frames(@s11_v_frame, 2, :v, @s11_h_frame[0])
    @s11_frames = []; add_frames(@s11_frames, 6, :h, @s11_v_frame[0])
    
    @s11_frames.each do |i|
    i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
    i.height = 82
    end
        @s11_icons = []; add_icons(@s11_icons,"games/11/icons",49)
        @s11_image = []
          add_buttons(@s11_image,10,@s11_frames[0])
          add_buttons(@s11_image,10,@s11_frames[1])
          add_buttons(@s11_image,10,@s11_frames[2])
          add_buttons(@s11_image,10,@s11_frames[3])
          add_buttons(@s11_image,9,@s11_frames[4])
          @s11_image.each_with_index{|e,i| e.icon = @s11_icons[i]}
      @s11_screen = 0
      @s11_temp = 0
      @s11_count = 0
      @s11_sound = FXButton.new(@s11_v_frame[1], nil, @sound_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND){sound_play(0,"games/11/audio")}
      @s11_frames[5].height = 102
      FXButton.new(@s11_frames[5], nil, @back_ico_big, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND) do 
        @s11_useful_frame[1].width = 0
        @s11_useful_frame[0].width = 1050
        s11_refresh_choise
        sound_wrong
      end
        @s11_frames_speed = []; add_frames(@s11_frames_speed,4,:h, @s11_frames[5])
        @s11_frames_speed0 = []; 
         add_frames(@s11_frames_speed0,1,:v, @s11_frames_speed[0])
          add_frames(@s11_frames_speed0,1,:v, @s11_frames_speed[1])
         @s11_frames_speed0.each do |i|
          i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
          i.height = 102
          end
        @s11_speed = []
            add_buttons(@s11_speed,1,@s11_frames_speed0[0])
            add_buttons(@s11_speed,1,@s11_frames_speed0[1])
            @s11_speed.each_with_index do |e,i|
              e.icon = @speed_icons[i]
              e.connect(SEL_COMMAND) do 
                sound_play(i.to_s,"games/11/audio/speed")
                @s11_temp = i
              end
            end  
            @s11_frames_s = []
            @s11_frames_s <<FXHorizontalFrame.new(@s11_frames_speed0[0], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
            @s11_frames_s <<FXHorizontalFrame.new(@s11_frames_speed0[1], :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
      @s11_accepts = []
          add_buttons(@s11_accepts,1,@s11_frames_s[0])
          add_buttons(@s11_accepts,1,@s11_frames_s[1])
      @s11_declines = []
          add_buttons(@s11_declines,1,@s11_frames_s[0])
          add_buttons(@s11_declines,1,@s11_frames_s[1])
      @s11_choise = []
          add_buttons(@s11_choise,1,@s11_frames_s[0])
          add_buttons(@s11_choise,1,@s11_frames_s[1])

          
          @s11_accepts.each_with_index do |e, i| 
            e.connect(SEL_COMMAND)do 
              @s11_choise[i].icon = @accepts[1]
              @s11_accepts[i].icon = nil
              @s11_declines[i].icon = nil
              change_score(@score_global,:s)
              sounds_right
            end
          end  
          @s11_declines.each_with_index do |e, i| 
            e.connect(SEL_COMMAND)do 
              @s11_choise[i].icon = @declines[1]
              @s11_accepts[i].icon = nil
              @s11_declines[i].icon = nil
              change_score(@score_global,:t)
              sounds_wrong
            end
          end  
      
  def s11_refresh_choise
    @s11_accepts.each {|i| i.icon = @accepts[0]}
    @s11_declines.each {|i| i.icon = @declines[0]}
    @s11_choise.each {|i| i.icon = nil}
  end
  s11_refresh_choise
######################################### 12 Screen  ###########################################

  @s12_frames = []; add_frames(@s12_frames, 6, :h, @screens[12])
      @s12_frames.each do |i|
        i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
        i.height = 82
        end
  @s12_end_frame = []; add_frames(@s12_end_frame, 1, :h, @screens[12])      
      @s12_end_frame[0].layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
      @s12_end_frame[0].height = 0
      @s12_answered = []      
      @s12_icons = []; add_icons(@s12_icons,"games/11/icons",49)
      @s12_image = []
        add_buttons(@s12_image,10,@s12_frames[0])
        add_buttons(@s12_image,10,@s12_frames[1])
        add_buttons(@s12_image,10,@s12_frames[2])
        add_buttons(@s12_image,10,@s12_frames[3])
        add_buttons(@s12_image,9,@s12_frames[4])
        @s12_image.each_with_index{|e,i| e.icon = @s12_icons[i]}
    @s12_count = 0
    @s12_frames[5].height = 100
    @s12_sound = FXButton.new(@s12_frames[5], nil, @sound_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND){sound_play('0',"games/12/audio")}
    @s12_answers = [4,6,8,10,18,20,24,27,31,32,33,43,45,46]
    def s12_end_game(i)
      if i == 0
        @s12_end_frame[0].height = 0
        @s12_frames.each do |i|
        i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
        i.height = 82
        @s12_frames[5].height = 100
        @s12_count = 0
        @s12_answered = []
        end

      else
        @s12_end_frame[0].height = 100
        @s12_frames.each do |i|
        i.layoutHints = LAYOUT_CENTER_Y|LAYOUT_CENTER_X|LAYOUT_FIX_HEIGHT
        i.height = 0
        end

      end
    end
    @s12_end = FXButton.new(@s12_end_frame[0], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X).connect(SEL_COMMAND)do 
    s12_end_game(0);change_screen(0)
    end
    
    @s12_image.each_with_index do |e,i|
      e.connect(SEL_COMMAND) do
          if @s12_answers.include? i
            if @s12_answered.include? i
              sound_wrong
            else
              @s12_answered << i 
              change_score(@score_global,:s)
              sounds_right
              @s12_count +=1
                if @s12_count == 14
                  s12_end_game(1)
                end
            end
          else 
            change_score(@score_global,:t)
            sounds_wrong
          end
      end
    end
########################################## EndScreen ###########################################    
    def scores_end(frame,arr)
      arr << FXButton.new(frame,"Учень:#{@score}",nil, :opts => FRAME_GROOVE|LAYOUT_LEFT)
      arr[0].font = @fontdecorative
      arr << FXButton.new(frame,"Вчитель:#{@scoret}",nil, :opts => FRAME_GROOVE|LAYOUT_RIGHT)
      arr[1].font = @fontdecorative
    end
    @end_frame = []; add_frames(@end_frame,2,:h,@screens[13])
        @end_frame[1].layoutHints = LAYOUT_FIX_WIDTH|LAYOUT_CENTER_X
        @end_frame[1].width = 800
    @end_game = FXButton.new(@end_frame[0], nil, @end_ico, :opts => LAYOUT_CENTER_Y|LAYOUT_CENTER_X)
    @score_end = []; scores_end(@end_frame[1],@score_end)
    @exit_button.connect(SEL_COMMAND) do 
      change_screen(0)
      sound_wrong
      s11_refresh_choise
      s1_change_screen(0)
      @s1_game = 0
      @s1_screens = 0
      @s1_count = 0
      
      @s2_screen = 0
      @s2_num = 0
      s2_change_screen
      s2_double_change(0,0)

      
      s3_end_game(2)
      @s3_screen = 0
      @s3_num = 0
      s3_change_screen
      s3_double_change(0,0)

      
      s4_end_game(2)
      @s4_screen = 0
      @s4_num = 0
      s4_change_screen
      s4_double_change(0,0)

      
      @s5_screen = 0
      s5_change_screen

      
      s6_end_game(2)
      @s6_screen = 0
      @s6_num = 0
      s6_change_screen

      
      s7_end_game(2)
      @s7_screen = 0
      @s7_num = 0
      s7_change_screen


      @s8_screen = 0
      @s8_temp = 0
      @s8_count = 0
      s8_change_screen

      s12_end_game(0)

      @s9_screen = 0
      @s9_temp = 0
      @s9_count = 0
      s9_change_screen
      
      @s10_screen = 0
      @s10_temp = 0
      @s10_count = 0
      s10_change_screen

    end
    @end_game.connect(SEL_COMMAND) do 
      change_screen(0)
    end
########################################### Loading ############################################
  loadframe = FXHorizontalFrame.new(full_screen_main, :opts => LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 0, :height => 0 )
   FXButton.new(loadframe,nil,@null200_ico)
  FXButton.new(loadframe,nil,@null150_ico)
  FXButton.new(loadframe,nil,@null160_ico)
  FXButton.new(loadframe,nil,@next_ico)
  
  FXButton.new(loadframe,nil,@nil102)
  FXButton.new(loadframe,nil,@end_ico)
  FXButton.new(loadframe,nil,@next_ico_big)
  FXButton.new(loadframe,nil,@back_ico_big)
  @declines.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @accepts.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s2_icons.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s10_imgs.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s2_top_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s9_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s10_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s6_icons.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s8_icons.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s6_top_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s5_left_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s5_right_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s7_icons.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s7_top_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s3_icons.each do |i|
    FXButton.new(loadframe,nil,i)
  end
  @s3_top_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s4_top_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s4_icons.each do |z|
    z.each do |i|
    FXButton.new(loadframe,nil,i)
    end
  end
  @s1_icons.each do |a|
    a.each do |b|
      b.each do |i|
        FXButton.new(loadframe,nil,i)
      end
    end
  end    
#########################################
end                                     #
end                                     #
    def create                          #        
      super                             #
      show(PLACEMENT_MAXIMIZED)         #
    end                                 #
  end                                   #
  def run                               #
    application = FXApp.new             #
    MainWindow.new(application)         #
    application.create                  #
    application.run                     #
  end                                   #
  run                                   #
  #######################################
