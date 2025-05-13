#!/bin/bash
# Skrypt do nauki słówek w języku obcym

echo "Uruchomiono Fiszki"
voice_enabled=false
all_good=0
all_rounds=0

speak() {
  if $voice_enabled; then
    local text="$1"
    local lang="${2:-en}"  
    espeak -v "$lang" "$text" &
  fi
}

start_learning() {
  if [[ ${#word_pairs[@]} -eq 0 ]]; then
    echo "Brak słówek do nauki. Wczytaj je najpierw."
    return
  fi

  correct=0
  incorrect=0

  for pair in "${word_pairs[@]}"; do
    clear
    native_word="${pair%%$separator*}"
    foreign_word="${pair#*$separator}"

    speak "$native_word" "pl"
    sleep 0.1
    read -p "Przetłumacz: $native_word → " answer

    answer=$(echo "$answer" | xargs | tr '[:upper:]' '[:lower:]')
    foreign_word=$(echo "$foreign_word" | xargs | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "$foreign_word" ]]; then
      speak "$native_word" "pl"
      echo "✅ Poprawnie!"
      ((correct++))
      ((all_good++))  # Zwiększa statystykę dla całej sesji
    else
      echo "❌ Błąd. Poprawna odpowiedź: $foreign_word"
      speak "$native_word" "pl"
      ((incorrect++))
    fi
    ((all_rounds++))  # Zwiększa liczbę rund w sesji

    read -p "Naciśnij Enter, aby kontynuować..."
  done

  clear
  total=$((correct + incorrect))
  percent=$(( 100 * correct / total ))

  echo ""
  echo "Wynik: $correct poprawnych, $incorrect błędnych"
  echo "Skuteczność: $percent%"
  read -p "Naciśnij Enter, aby wrócić do menu..."
}

file() {
  clear
  read -p "Podaj separator (np. =): " separator
  read -p "Podaj ścieżkę do pliku: " filepath

  if [[ ! -f "$filepath" ]]; then
    echo "Plik nie istnieje."
    return
  fi

  word_pairs=()
  while IFS= read -r line; do
    if [[ "$line" == *"$separator"* ]]; then
      word_pairs+=("$line")
    fi
  done < "$filepath"

  echo "Wczytano ${#word_pairs[@]} słówek."
  read -p "Naciśnij Enter, aby kontynuować..."
}

keyboard() {
  clear
  read -p "Podaj separator (np. =): " separator
  echo "Wpisuj pary słówek w formacie: polskie${separator}angielskie"
  echo "Aby zakończyć, wpisz: koniec"
  echo ""

  word_pairs=()
  while true; do
    read -p ">> " line

    if [[ "$line" == "koniec" ]]; then
      break
    fi

    if [[ "$line" == *"$separator"* ]]; then
      word_pairs+=("$line")
    else
      echo "❌ Niepoprawny format. Użyj separatora '$separator'."
    fi
  done

  echo ""
  echo "✅ Dodano ${#word_pairs[@]} słówek."
  read -p "Naciśnij Enter, aby kontynuować..."
}

Output() {
  clear
  echo "==== Ustawienia wyjścia ===="
  echo "1. Z dźwiękiem (espeak)"
  echo "2. Bez dźwięku"
  echo "============================="
  read -p "Wybierz (1-2): " out_choice

  case $out_choice in
    1)
      voice_enabled=true
      echo "Dźwięk włączony."
      ;;
    2)
      voice_enabled=false
      echo "Dźwięk wyłączony."
      ;;
    *)
      echo "Niepoprawny wybór"
      ;;
  esac

  read -p "Naciśnij Enter, aby kontynuować..."
}

input() {
  while true; do
    clear
    echo ""
    echo "==== Typ wejścia ===="
    echo "  1. Wejście z pliku"
    echo "  2. Wejście z klawiatury"
    echo "  3. Powrót"
    echo "======================"
    read -p "Wybierz opcję (1-3): " input_choice

    case $input_choice in
      1)
        file
        ;;
      2)
        keyboard
        ;;
      3)
        break
        ;;
      *)
        echo "Niepoprawny wybór, spróbuj ponownie."
        read -p "Naciśnij Enter, aby kontynuować..."
        ;;
    esac
  done
}

settings() {
  while true; do
    clear
    echo ""
    echo "==== Ustawienia ===="
    echo "  1. Typ wejścia"
    echo "  2. Typ wyjścia"
    echo "  3. Powrót"
    echo "====================="
    read -p "Wybierz opcję (1-3): " settings_choice

    case $settings_choice in
      1)
        input
        ;;
      2)
        Output
        ;;
      3)
        break
        ;;
      *)
        echo "Niepoprawny wybór, spróbuj ponownie."
        read -p "Naciśnij Enter, aby kontynuować..."
        ;;
    esac
  done
}

show_menu() {
  clear
  echo ""
  echo "==========================="
  echo "Wybierz opcję:"
  echo "1) Nauka słówek"
  echo "2) Statystyki"
  echo "3) Ustawienia"
  echo "4) Wyjście"
  echo "==========================="
}

show_statistics() {
  clear
  echo "Statystyki tej sesji: "
  echo "Poprawne odpowiedzi = $all_good/$all_rounds"
  read -p "Naciśnij Enter, aby wrócić do menu..."
}

while true; do
  show_menu
  read -p "Wybierz opcję (1-4): " choice

  case $choice in
    1)
      start_learning
      ;;
    2)
      show_statistics
      ;;
    3)
      settings
      ;;
    4)
      echo "Dziękujemy za korzystanie z programu!"
      exit 0
      ;;
    *)
      echo "Niepoprawny wybór, spróbuj ponownie."
      read -p "Naciśnij Enter, aby kontynuować..."
      ;;
  esac
done
