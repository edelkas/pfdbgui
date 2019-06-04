#require 'devil'
require 'tk'
#require 'tkextlib/tkimg'
#require_relative 'pfdb.rb'
require 'yaml'

CONFIG_ENV = 'production'
CONFIG = YAML.load_file('config.yml')[CONFIG_ENV]

#<----------------------------------------------------------------------------->
#<------------------------------------ LIB ------------------------------------>
#<----------------------------------------------------------------------------->

#startup

#<----------------------------------------------------------------------------->
#<------------------------------------ GUI ------------------------------------>
#<----------------------------------------------------------------------------->

# CONSTANTS AND IMAGES

$colors = {
  background: 'ivory',#'antique white',
  background2: 'khaki1',
  button_header: 'grey',
  button_header_highlight: 'sandy brown',
  button_list_light: 'LightSkyBlue1',
  button_list_dark: 'SteelBlue1',
  button_list_highlight: 'PaleGreen2',
  title_film: 'saddle brown',
  title_field: 'saddle brown',
  border: 'black'
}

# ROOT WINDOW

root = TkRoot.new('title' => 'PFDB', 'background' => $colors[:background])
root.grid_rowconfigure(3, 'weight' => 1)
root.grid_columnconfigure(0, 'weight' => 1)
icon = TkPhotoImage.new('file' => 'icons/icon.gif')
root.iconphoto(icon)
$root = root

# BASIC SUBCLASSES

class DisplayLabel < TkLabel
  def initialize(frame, text, row, column)
    option_hash = {
      'background' => $colors[:background2],
      'foreground' => $colors[:title_field],
      'borderwidth' => 0,
      'highlightthickness' => 0,
      'padx' => 0,
      'pady' => 0,
      'text' => text,
      'font' => "times 12 bold"
    }
    temp_label = TkLabel.new(root, option_hash)
    temp_frame = TkFrame.new(frame, 'height' => 18, 'width' => temp_label.winfo_reqwidth)
      .grid('row' => row, 'column' => column, 'padx' => 0, 'pady' => 0, 'ipadx' => 0, 'ipady' => 0, 'sticky' => 'e').pack_propagate(0)
    super(temp_frame, option_hash)
    self.pack('fill' => 'both', 'expand' => 1)
  end
end

class DisplayText < TkEntry
  def initialize(frame, text, row, column)
    super(frame, 'borderwidth' => 0, 'highlightthickness' => 0, 'background' => $colors[:background2], 'readonlybackground' => $colors[:background2], 'font' => 'times 12')
    self.insert(1, text).configure('state' => 'readonly')
    self.grid('row' => row, 'column' => column, 'padx' => 5, 'pady' => 0, 'ipadx' => 0, 'ipady' => 0, 'sticky' => 'ew')
  end
end

class Tooltip
  def initialize(widget, text = " ? ")
    @wait = 2000 # not in use, 'after' didnt work
    @wraplength = 180
    @widget = widget
    @text = text
    @label = nil
    @schedule = nil # not in use, 'after' didnt work
    @widget.bind("Enter"){ enter }
    @widget.bind("Leave"){ leave }
  end

  def enter
    # Absolute coordinates of pointer with respect to screen minus the same for the root window
    # equals absolute coordinates of pointer with respect to the root window
    x = @widget.winfo_pointerx - $root.winfo_rootx + 10
    y = @widget.winfo_pointery - $root.winfo_rooty + 10
    @label = TkLabel.new($root, 'text' => @text, 'justify' => 'left', 'background' => "#ffffff", 'relief' => 'solid', 'borderwidth' => 1, 'wraplength' => @wraplength)
    @label.place('x' => x, 'y' => y) # Absolute coordinates with respect to the root window
  end

  def leave
    @label.place_forget
    @label = nil
  end
end

class Button < TkButton
  def initialize(frame, image, row, column, tooltip, padx = 0, pady = 0)
    super(frame, 'background' => $colors[:background], 'image' => TkPhotoImage.new('file' => image))
    self.grid('row' => row, 'column' => column, 'sticky' => 'nsew', 'padx' => padx, 'pady' => pady)
    if !tooltip.nil? && !tooltip.empty? then Tooltip.new(self, tooltip) end
  end
end

class DisplayButton < TkButton
  def initialize(frame, text, color = $colors[:button_header])
    option_hash = {
      'anchor' => 'w',
      'height' => 1,
      'borderwidth' => 0,
      'highlightthickness' => 1,
      'background' => color,
      'activebackground' => $colors[:button_header_highlight],
      'text' => text
    }
    super(frame, option_hash)
    self.pack('side' => 'left')
  end
end

class TitleLabel < TkLabel
  def initialize(frame, text, row = 0, column = 0)
    option_hash = {
      'background' => $colors[:background],
      'foreground' => $colors[:title_film],
      'height' => 1,
      'borderwidth' => 0,
      'highlightthickness' => 0,
      'padx' => 0,
      'pady' => 0,
      'text' => text,
      'font' => "times 20 bold"
    }
    temp_label = TkLabel.new(root, option_hash)
    temp_frame = TkFrame.new(frame, 'height' => 24, 'width' => temp_label.winfo_reqwidth)
      .grid('row' => row, 'column' => column, 'padx' => 0, 'pady' => 0, 'ipadx' => 0, 'ipady' => 0, 'sticky' => 'ew').pack_propagate(0)
    super(temp_frame, option_hash)
    self.pack('fill' => 'both', 'expand' => 1)
  end
end

class InfoFrame < TkFrame
  def initialize(frame)
    super(frame, 'background' => $colors[:background2], 'highlightthickness' => 1, 'highlightbackground' => $colors[:border], 'padx' => 5)
  end
end

# OPTIONS

options = TkFrame.new(root){
  background $colors[:background]
  grid('row' => 0, 'column' => 0, 'columnspan' => 2, 'sticky' => 'nsew')
}
options.grid_columnconfigure(9, 'weight' => 1)
new_button = Button.new(options, 'icons/new.gif', 0, 0, "Nueva base de datos")
open_button = Button.new(options, 'icons/open.gif', 0, 1, "Abrir base de datos")
save_button = Button.new(options, 'icons/save.gif', 0, 2, "Guardar base de datos")
search_button = Button.new(options, 'icons/search.gif', 0, 3, "Buscar película")
config_button = Button.new(options, 'icons/config.gif', 0, 4, "Configuración")
stats_button = Button.new(options, 'icons/stats.gif', 0, 5, "Estadísticas")
news_button = Button.new(options, 'icons/news.gif', 0, 6, "Noticias")
help_button = Button.new(options, 'icons/help.gif', 0, 7, "Ayuda")
info_button = Button.new(options, 'icons/info.gif', 0, 8, "Acerca de")
title = TitleLabel.new(options, 'Personal Film DataBase v2019.06.01', 0, 9)

# SEARCH

search_bar = TkFrame.new(root){
  background $colors[:background]
  grid('row' => 1, 'column' => 0, 'columnspan' => 2, 'sticky' => 'nsew')
}
$search_text = TkEntry.new(search_bar){
  background 'white'
  grid('row' => 0, 'column' => 0, 'sticky' => 'ew', 'padx' => 5)
}
search_bar.grid_columnconfigure(0, 'weight' => 1)
search_button = TkButton.new(search_bar){
  height 1
  borderwidth 1
  background $colors[:button_header]
  activebackground $colors[:button_header_highlight]
  text 'Buscar'
  grid('row' => 0, 'column' => 1, 'sticky' => 'ew')
}
first_page_button = Button.new(search_bar, 'icons/first.gif', 0, 2, "Primera página")
previous_page_button = Button.new(search_bar, 'icons/previous.gif', 0, 3, "Anterior página")
page = TitleLabel.new(search_bar, '1 / 1', 0, 4)
next_page_button = Button.new(search_bar, 'icons/next.gif', 0, 5, "Siguiente página")
last_page_button = Button.new(search_bar, 'icons/last.gif', 0, 6, "Última página")

# SCROLLBARS

scroll_list = TkScrollbar.new(root) do
   orient 'vertical'
   grid('row' => 2, 'column' => 1, 'sticky' => 'ns')
end
scroll_display = TkScrollbar.new(root) do
   orient 'vertical'
   grid('row' => 3, 'column' => 1, 'sticky' => 'ns')
end

# FILM LIST

$list = TkFrame.new(root){
   background $colors[:background]
   grid('row' => 2, 'column' => 0, 'sticky' => 'nsew')
}
$list.grid_columnconfigure(0, 'weight' => 1)

$headers = {title: "Título", year: "Año", genres: "Géneros", duration: "Duración"}
$movies = [
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'El Padrino', year: 1972, genres: ["Mafia", "Drama"], duration: 180},
  {title: 'Matrix', year: 1999, genres: ["Science Fiction", "Action"], duration: 120},
  {title: 'Terminator', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Bullshit', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Final', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Final', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Final', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Final', year: 1984, genres: ["Action", "Science Fiction"], duration: 130},
  {title: 'Final', year: 1984, genres: ["Action", "Science Fiction"], duration: 130}
]
$movies_frame = $movies[0..CONFIG['movies_per_page']].map{ |m| m.map{ |k, v| [k, !v.is_a?(Array) ? v.to_s : v.map(&:to_s).join(", ")] }.to_h }

column_width_limits = {title: 50, year: 15, genres: 50, duration: 15} # hardcoded limits, make them configurable
$column_widths = $movies_frame.map{ |s| s.values.flatten(0).map{ |r| r.to_s.size } }.transpose.each_with_index.map{ |s, i| [(s + [$headers.values[i].size]).max, column_width_limits.values[i]].min }
$header_buttons = []
$list_buttons = []

$headers.each_with_index{ |h, j|
  $header_buttons << TkButton.new($list){
    height 1
    width $column_widths[j]
    borderwidth 0
    highlightthickness 1
    background $colors[:button_header]
    activebackground $colors[:button_header_highlight]
    text h[1]
    bind('Button-1'){
      $movies_frame.sort_by!{ |m| m[h[0]] }
      populate_list
    }
    grid('row' => 0, 'column' => j, 'sticky' => 'ew')
  }
}
def populate_list
  $list_buttons.each{ |b| if b.respond_to?(:place_forget) then b.place_forget end }
  $list_buttons = []
  $movies_frame.each_with_index{ |m, i|
    m.each_with_index{ |field, j|
      texto = !field[1].is_a?(Array) ? field[1].to_s : field[1].map(&:to_s).join(", ")
      color = i % 2 == 0 ? $colors[:button_list_light] : $colors[:button_list_dark]
      pos = field[1].is_a?(Integer) ? 'e' : 'w'
      $list_buttons << TkButton.new($list){
        anchor 'w'
        height 1
        width $column_widths[j]
        borderwidth 0
        highlightthickness 0
        background color
        activebackground $colors[:button_list_highlight]
        text texto
        grid('row' => i + 1, 'column' => j, 'sticky' => 'ew')
      }
    }
  }
end
populate_list

# FILM DISPLAY

display = TkFrame.new(root, 'background' => $colors[:background]).grid('row' => 3, 'column' => 0, 'sticky' => 'nsew')
display.grid_rowconfigure(1, 'weight' => 1)
display.grid_columnconfigure(1, 'weight' => 1)

display_header = TkFrame.new(display, 'background' => $colors[:background]).grid('row' => 0, 'column' => 0, 'columnspan' => 3, 'sticky'=> 'ew')
display_header.grid_columnconfigure(2, 'weight' => 1)
first_button = Button.new(display_header, 'icons/first.gif', 0, 0, "Primera")
previous_button = Button.new(display_header, 'icons/previous.gif', 0, 1, "Anterior")
TitleLabel.new(display_header, 'El Padrino', 0, 2)
next_button = Button.new(display_header, 'icons/next.gif', 0, 3, "Siguiente")
last_button = Button.new(display_header, 'icons/last.gif', 0, 4, "Última")

film_options = TkFrame.new(display, 'background' => $colors[:background]).grid('row' => 1, 'column' => 0, 'sticky' => 'n')
update_button = Button.new(film_options, 'icons/update.gif', 0, 0, "Actualizar información desde internet")
edit_button = Button.new(film_options, 'icons/edit.gif', 1, 0, "Editar información manualmente")
delete_button = Button.new(film_options, 'icons/delete.gif', 2, 0, "Eliminar película")
fav_button = Button.new(film_options, 'icons/fav.gif', 3, 0, "Marcar como favorita")
seen_button = Button.new(film_options, 'icons/seen.gif', 4, 0, "Marcar como vista")

display_info = TkFrame.new(display, 'background' => $colors[:background])
display_info.grid('row' => 1, 'column' => 1, 'sticky' => 'nsew')
display_tabs = TkFrame.new(display_info, 'background' => $colors[:background]).pack('side' => 'top', 'fill' => 'x')
display_frame = InfoFrame.new(display_info).pack('side' => 'bottom', 'fill' => 'both', 'expand' => 1)
display_frame.grid_columnconfigure(1, 'weight' => 1)

basic_info_button = DisplayButton.new(display_tabs, 'Básica', $colors[:background2])
tech_info_button = DisplayButton.new(display_tabs, 'Técnica', $colors[:background2])
tech_info_button = DisplayButton.new(display_tabs, 'Sinopsis', $colors[:background2])
tech_info_button = DisplayButton.new(display_tabs, 'Cast', $colors[:background2])
DisplayLabel.new(display_frame, "Título original:", 0, 0)
DisplayLabel.new(display_frame, "Año:", 1, 0)
DisplayLabel.new(display_frame, "Duración:", 2, 0)
DisplayLabel.new(display_frame, "País:", 3, 0)
DisplayLabel.new(display_frame, "Dirección:", 4, 0)
DisplayLabel.new(display_frame, "Guión:", 5, 0)
DisplayLabel.new(display_frame, "Producción:", 6, 0)
DisplayLabel.new(display_frame, "Cinematografía:", 7, 0)
DisplayLabel.new(display_frame, "Música:", 8, 0)
DisplayLabel.new(display_frame, "Edición:", 9, 0)
DisplayText.new(display_frame, "El Padrino", 0, 1)
DisplayText.new(display_frame, "1972", 1, 1)
DisplayText.new(display_frame, "175 min.", 2, 1)
DisplayText.new(display_frame, "United States", 3, 1)
DisplayText.new(display_frame, "Francis Ford Coppola", 4, 1)
DisplayText.new(display_frame, "Mario Puzo, Francis Ford Coppola", 5, 1)
DisplayText.new(display_frame, "Gray Frederickson, Al Ruddy, Robert Evans", 6, 1)
DisplayText.new(display_frame, "Gordon Willis", 7, 1)
DisplayText.new(display_frame, "Nino Rota", 8, 1)
DisplayText.new(display_frame, "William Reynolds, Peter Zinner", 9, 1)

=begin
tech_info = InfoFrame.new(display_info).grid('row' => 1, 'column' => 2, 'sticky' => 'ew')
display_info.add(tech_info, text: 'Información técnica')
DisplayLabel.new(tech_info, "Nota IMDb:", 0, 0)
DisplayLabel.new(tech_info, "Nota FilmAffinity:", 1, 0)
DisplayLabel.new(tech_info, "Color:", 2, 0)
DisplayLabel.new(tech_info, "Idiomas:", 3, 0)
DisplayText.new(tech_info, "9.2 (1437693 votos)", 0, 1)
DisplayText.new(tech_info, "9.0 (176014 votos)", 1, 1)
DisplayText.new(tech_info, "Color (Eastman Color)", 2, 1)
DisplayText.new(tech_info, "English, Italian", 3, 1)

crew_info = InfoFrame.new(display).grid('row' => 2, 'column' => 1, 'padx' => 5, 'pady' => 5, 'sticky' => 'new')
DisplayLabel.new(crew_info, "Dirección:", 0, 0)
DisplayLabel.new(crew_info, "Guión:", 1, 0)
DisplayLabel.new(crew_info, "Producción:", 2, 0)
DisplayLabel.new(crew_info, "Cinematografía:", 3, 0)
DisplayLabel.new(crew_info, "Música:", 4, 0)
DisplayLabel.new(crew_info, "Edición:", 5, 0)
DisplayText.new(crew_info, "Francis Ford Coppola", 0, 1)
DisplayText.new(crew_info, "Mario Puzo, Francis Ford Coppola", 1, 1)
DisplayText.new(crew_info, "Gray Frederickson, Al Ruddy, Robert Evans", 2, 1)
DisplayText.new(crew_info, "Gordon Willis", 3, 1)
DisplayText.new(crew_info, "Nino Rota", 4, 1)
DisplayText.new(crew_info, "William Reynolds, Peter Zinner", 5, 1)

cast_info = InfoFrame.new(display).grid('row' => 2, 'column' => 2, 'pady' => 5, 'sticky' => 'new')
DisplayLabel.new(cast_info, "Marlon Brando:", 0, 0)
DisplayLabel.new(cast_info, "Al Pacino:", 1, 0)
DisplayLabel.new(cast_info, "James Caan:", 2, 0)
DisplayLabel.new(cast_info, "Richard S. Castellano:", 3, 0)
DisplayLabel.new(cast_info, "Robert Duvall:", 4, 0)
DisplayLabel.new(cast_info, "Sterling Hayden:", 5, 0)
DisplayText.new(cast_info, "Don Vito Corleone", 0, 1)
DisplayText.new(cast_info, "Michael Corleone", 1, 1)
DisplayText.new(cast_info, "Sonny Corleone", 2, 1)
DisplayText.new(cast_info, "Clemenza (as Richard Castellano)", 3, 1)
DisplayText.new(cast_info, "Tom Hagen", 4, 1)
DisplayText.new(cast_info, "Capt. McCluskey", 5, 1)
=end

TkLabel.new(display, 'image' => TkPhotoImage.new('file' => 'notfound.gif')).grid('row' => 1, 'column' => 2)

# GUI MAIN LOOP

Tk.mainloop
