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
root.grid_rowconfigure(1, 'weight' => 2)
root.grid_rowconfigure(2, 'weight' => 1)
root.grid_columnconfigure(0, 'weight' => 1)
icon = TkPhotoImage.new('file' => 'icons/icon.gif')
root.iconphoto(icon)
$root = root

# BASIC SUBCLASSES

class DisplayLabel < TkLabel
  def initialize(frame, text = "")
    super(frame, 'height' => 1, 'borderwidth' => 0, 'highlightthickness' => 0, 'background' => $colors[:background2], 'foreground' => $colors[:title_field], 'font' => 'times 12 bold', 'text' => text)
  end
end

class DisplayText < TkText
  def initialize(frame, text = "")
    super(frame, 'height' => 1, 'width' => 10, 'borderwidth' => 0, 'highlightthickness' => 0, 'background' => $colors[:background2], 'font' => 'times 12')
    self.insert(1.0, text).configure('state' => 'disabled')
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
new_button = Button.new(options, 'icons/new.gif', 0, 0, "Nueva base de datos")
open_button = Button.new(options, 'icons/open.gif', 0, 1, "Abrir base de datos")
save_button = Button.new(options, 'icons/save.gif', 0, 2, "Guardar base de datos")
search_button = Button.new(options, 'icons/search.gif', 0, 3, "Buscar película")
config_button = Button.new(options, 'icons/config.gif', 0, 4, "Configuración")
stats_button = Button.new(options, 'icons/stats.gif', 0, 5, "Estadísticas")
news_button = Button.new(options, 'icons/news.gif', 0, 6, "Noticias")
help_button = Button.new(options, 'icons/help.gif', 0, 7, "Ayuda")
info_button = Button.new(options, 'icons/info.gif', 0, 8, "Acerca de")
title = TkLabel.new(options) do
  background $colors[:background]
  foreground $colors[:title_film]
  text 'Personal Film DataBase v2019.06.01'
  font 'times 20 bold'
  padx 5
  grid('row' => 0, 'column' => 9)
end

# SCROLLBARS

scroll_list = TkScrollbar.new(root) do
   orient 'vertical'
   grid('row' => 1, 'column' => 1, 'sticky' => 'ns')
end

scroll_display = TkScrollbar.new(root) do
   orient 'vertical'
   grid('row' => 2, 'column' => 1, 'sticky' => 'ns')
end

# FILM LIST

$list = TkFrame.new(root){
   background $colors[:background]
   grid('row' => 1, 'column' => 0, 'sticky' => 'nsew')
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
    #highlightthickness 0
    #highlightbackground 'red'
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

display = TkFrame.new(root){
  background $colors[:background]
  grid('row' => 2, 'column' => 0, 'sticky' => 'nsew')
}

display_header = TkFrame.new(display){
  background $colors[:background]
  grid('row' => 0, 'column' => 0, 'columnspan' => 4)
}
TkLabel.new(display_header) do
  background $colors[:background]
  foreground $colors[:title_film]
  text 'El Padrino'
  font 'times 20 bold'
  padx 5
  grid('row' => 0, 'column' => 2)
end
first_button = Button.new(display_header, 'icons/first.gif', 0, 0, "Primera", 5)
previous_button = Button.new(display_header, 'icons/previous.gif', 0, 1, "Anterior", 5)
next_button = Button.new(display_header, 'icons/next.gif', 0, 3, "Siguiente", 5)
last_button = Button.new(display_header, 'icons/last.gif', 0, 4, "Última", 5)

film_options = TkFrame.new(display){
  background $colors[:background]
  grid('row' => 1, 'column' => 0, 'rowspan' => 2, 'sticky' => 'ns')
}
update_button = Button.new(film_options, 'icons/update.gif', 0, 0, "Actualizar información desde internet", 5)
edit_button = Button.new(film_options, 'icons/edit.gif', 1, 0, "Editar información manualmente", 5)
delete_button = Button.new(film_options, 'icons/delete.gif', 2, 0, "Eliminar película", 5)
fav_button = Button.new(film_options, 'icons/fav.gif', 3, 0, "Marcar como favorita", 5)
seen_button = Button.new(film_options, 'icons/seen.gif', 4, 0, "Marcar como vista", 5)

basic_info = InfoFrame.new(display).grid('row' => 1, 'column' => 1, 'padx' => 5, 'sticky' => 'ew')
DisplayLabel.new(basic_info, "Título original:").grid('row' => 0, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(basic_info, "Año:").grid('row' => 1, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(basic_info, "Duración:").grid('row' => 2, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(basic_info, "País:").grid('row' => 3, 'column' => 0, 'sticky' => 'e')
DisplayText.new(basic_info, "El Padrino").grid('row' => 0, 'column' => 1, 'sticky' => 'w')
DisplayText.new(basic_info, "1972").grid('row' => 1, 'column' => 1, 'sticky' => 'w')
DisplayText.new(basic_info, "175 min.").grid('row' => 2, 'column' => 1, 'sticky' => 'w')
DisplayText.new(basic_info, "United States").grid('row' => 3, 'column' => 1, 'sticky' => 'w')

tech_info = InfoFrame.new(display).grid('row' => 1, 'column' => 2, 'sticky' => 'ew')
DisplayLabel.new(tech_info, "Nota IMDb:").grid('row' => 0, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(tech_info, "Nota FilmAffinity:").grid('row' => 1, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(tech_info, "Color:").grid('row' => 2, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(tech_info, "Idiomas:").grid('row' => 3, 'column' => 0, 'sticky' => 'e')
DisplayText.new(tech_info, "9.2 (1437693 votos)").grid('row' => 0, 'column' => 1, 'sticky' => 'w')
DisplayText.new(tech_info, "9.0 (176014 votos)").grid('row' => 1, 'column' => 1, 'sticky' => 'w')
DisplayText.new(tech_info, "Color (Eastman Color)").grid('row' => 2, 'column' => 1, 'sticky' => 'w')
DisplayText.new(tech_info, "English, Italian").grid('row' => 3, 'column' => 1, 'sticky' => 'w')

TkLabel.new(display, 'image' => TkPhotoImage.new('file' => 'notfound.gif'))
  .grid('row' => 1, 'column' => 3, 'rowspan' => 2, 'padx' => 5, 'pady' => 5)

crew_info = InfoFrame.new(display).grid('row' => 2, 'column' => 1, 'padx' => 5, 'pady' => 5)
DisplayLabel.new(crew_info, "Dirección:").grid('row' => 0, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(crew_info, "Guión:").grid('row' => 1, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(crew_info, "Producción:").grid('row' => 2, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(crew_info, "Cinematografía:").grid('row' => 3, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(crew_info, "Música:").grid('row' => 4, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(crew_info, "Edición:").grid('row' => 5, 'column' => 0, 'sticky' => 'e')
DisplayText.new(crew_info, "Francis Ford Coppola").grid('row' => 0, 'column' => 1, 'sticky' => 'w')
DisplayText.new(crew_info, "Mario Puzo, Francis Ford Coppola").grid('row' => 1, 'column' => 1, 'sticky' => 'w')
DisplayText.new(crew_info, "Gray Frederickson, Al Ruddy, Robert Evans").grid('row' => 2, 'column' => 1, 'sticky' => 'w')
DisplayText.new(crew_info, "Gordon Willis").grid('row' => 3, 'column' => 1, 'sticky' => 'w')
DisplayText.new(crew_info, "Nino Rota").grid('row' => 4, 'column' => 1, 'sticky' => 'w')
DisplayText.new(crew_info, "William Reynolds, Peter Zinner").grid('row' => 5, 'column' => 1, 'sticky' => 'w')

cast_info = InfoFrame.new(display).grid('row' => 2, 'column' => 2, 'pady' => 5)
DisplayLabel.new(cast_info, "Dirección:").grid('row' => 0, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "Marlon Brando:").grid('row' => 0, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "Al Pacino:").grid('row' => 1, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "James Caan:").grid('row' => 2, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "Richard S. Castellano:").grid('row' => 3, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "Robert Duvall:").grid('row' => 4, 'column' => 0, 'sticky' => 'e')
DisplayLabel.new(cast_info, "Sterling Hayden:").grid('row' => 5, 'column' => 0, 'sticky' => 'e')
DisplayText.new(cast_info, "Don Vito Corleone").grid('row' => 0, 'column' => 1, 'sticky' => 'w')
DisplayText.new(cast_info, "Michael Corleone").grid('row' => 1, 'column' => 1, 'sticky' => 'w')
DisplayText.new(cast_info, "Sonny Corleone").grid('row' => 2, 'column' => 1, 'sticky' => 'w')
DisplayText.new(cast_info, "Clemenza (as Richard Castellano)").grid('row' => 3, 'column' => 1, 'sticky' => 'w')
DisplayText.new(cast_info, "Tom Hagen").grid('row' => 4, 'column' => 1, 'sticky' => 'w')
DisplayText.new(cast_info, "Capt. McCluskey").grid('row' => 5, 'column' => 1, 'sticky' => 'w')

# GUI MAIN LOOP

Tk.mainloop
