import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeValidator {
  static String timeReamining(DateTime init) {
    String mensaje = "";
    int resta = init.difference(DateTime.now()).inSeconds;
    if (resta > 0) {
      if (resta < 60) {
        mensaje = "Empieza en menos de 1 minuto";
      } else if (resta >= 60 && resta < 3600) {
        mensaje = "Empieza en ${init.difference(DateTime.now()).inMinutes} min";
      } else if (resta >= 3600 && resta < 86400) {
        mensaje = "Empieza en ${_printDuration(Duration(seconds: resta))}";
        // _formatIntervalTime(x.hour, init.hour, x.minute, init.minute)}";
      } else if (resta >= 86400) {
        int different = dayDifferencesWithoutTime(init, DateTime.now());
        mensaje = "Empieza en $different ${different > 1 ? "días" : "día"}";
      }
    } else {
      mensaje =
          "En un momento podrás ingresar a la sala. Gracias por tu paciencia";
    }
    return mensaje;
  }

  static int dayDifferencesWithoutTime(DateTime x, DateTime y) {
    return dateWithoutTime(x).difference(dateWithoutTime(y)).inDays;
  }

  static String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    //String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours} ${duration.inHours > 1 ? 'horas' : 'hora'} $twoDigitMinutes min";
  }

  // static String _formatIntervalTime(
  //     int init, int end, int initmin, int endmin) {
  //   var sleepTime = end > init ? end - init : 23 - init + end; //De 24 a 25
  //   var minutes = endmin > initmin ? endmin - initmin : 60 - initmin + endmin;
  //   var horasd = (minutes > 0 && minutes < 60)
  //       ? (endmin > initmin && init > end)
  //           ? sleepTime + 1
  //           : sleepTime
  //       : sleepTime;
  //   String minu = (minutes == 0 || minutes == 60) ? '' : ' $minutes minutos';
  //   String showHora =
  //       horasd == 0 ? "" : "$horasd hora${horasd == 1 ? "" : "s"}";
  //   return '$showHora$minu';
  // }

  static String needZero(int i) {
    return (i >= 10) ? '$i' : '0$i';
  }

  static DateTime dateWithoutTime(DateTime x) =>
      DateTime(x.year, x.month, x.day);

  static DateTime dateandTime(DateTime fecha, TimeOfDay time) {
    return DateTime(fecha.year, fecha.month, fecha.day, time.hour, time.minute);
  }

  static TimeOfDay timeWithSubtractedMinutes(TimeOfDay time, int minutes) {
    return timefromDate(
        timeWithEmptyDate(time).add(Duration(minutes: -minutes)));
  }

  static DateTime timeWithEmptyDate(TimeOfDay time) {
    return DateTime(2020, 1, 2, time.hour, time.minute);
  }

  static TimeOfDay timefromDate(DateTime x) {
    return TimeOfDay(hour: x.hour, minute: x.minute);
  }

  static TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat("HH:mm:ss"); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  static DateTime stringtoDate(String s) {
    return DateFormat('yyyy-MM-dd').parse(s);
  }

  static String getDateTime(DateTime x) {
    return '${DateFormat('yyyy-MM-dd').format(x)}';
  }

  static int weekDifference(DateTime a, DateTime b) {
    int difference = a.compareTo(b);
    DateTime mayor = difference > 0 ? a : b;
    DateTime menor = difference > 0 ? b : a;
    int weekDayMayor = mayor.weekday;
    int weekDayMenor = menor.weekday;
    mayor = mayor.add(Duration(days: 7 - weekDayMayor));
    menor = menor.add(Duration(days: -(weekDayMenor)));
    final differenceWeek = (mayor.difference(menor).inDays / 7).round();
    return differenceWeek;
  }

  static String dateToString(DateTime x) => DateFormat('yyyy-MM-dd').format(x);

  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return "Januari";
        break;
      case 2:
        return "Februari";
        break;
      case 3:
        return "Maret";
        break;
      case 4:
        return "April";
        break;
      case 5:
        return "Mei";
        break;
      case 6:
        return "Juni";
        break;
      case 7:
        return "Juli";
        break;
      case 8:
        return "Agustus";
        break;
      case 9:
        return "September";
        break;
      case 10:
        return "Oktober";
        break;
      case 11:
        return "November";
        break;
      case 12:
        return "Desember";
        break;
      default:
        return "Januari";
        break;
    }
  }

  static String getMonthAbrevation3Letters(number) {
    String labelMonth = "";
    switch (number) {
      case 1:
        labelMonth = "Jan";
        break;
      case 2:
        labelMonth = "Feb";
        break;
      case 3:
        labelMonth = "Mar";
        break;
      case 4:
        labelMonth = "Apr";
        break;
      case 5:
        labelMonth = "Mei";
        break;
      case 6:
        labelMonth = "Jun";
        break;
      case 7:
        labelMonth = "Jul";
        break;
      case 8:
        labelMonth = "Ags";
        break;
      case 9:
        labelMonth = "Sep";
        break;
      case 10:
        labelMonth = "Okt";
        break;
      case 11:
        labelMonth = "Nov";
        break;
      case 12:
        labelMonth = "Des";
        break;
    }
    return labelMonth;
  }

  static int getDaysV2(String day) {
    switch (day) {
      case 'Sen':
        return 2;
        break;
      case 'Sel':
        return 3;
        break;
      case 'Rab':
        return 4;
        break;
      case 'Kam':
        return 5;
        break;
      case 'Jum':
        return 6;
        break;
      case 'Sab':
        return 7;
        break;
      case 'Min':
        return 1;
        break;
      default:
        return 1;
        break;
    }
  }

  static int getDaysV3(String day) {
    switch (day) {
      case 'Sen':
        return 2;
        break;
      case 'Sel':
        return 3;
        break;
      case 'Rab':
        return 4;
        break;
      case 'Kam':
        return 5;
        break;
      case 'Jum':
        return 6;
        break;
      case 'Sab':
        return 7;
        break;
      case 'Min':
        return 1;
        break;
      default:
        return 1;
        break;
    }
  }

  static String getDaysS(int day) {
    switch (day) {
      case 1:
        return 'Sen';
        break;
      case 2:
        return 'Sel';
        break;
      case 3:
        return 'Rab';
        break;
      case 4:
        return 'Kam';
        break;
      case 5:
        return 'Jum';
        break;
      case 6:
        return 'Sab';
        break;
      case 7:
        return 'Min';
        break;
      default:
        return 'Sen';
        break;
    }
  }

  static String getDaysC(int day) {
    switch (day) {
      case 1:
        return 'Senin';
        break;
      case 2:
        return 'Selasa';
        break;
      case 3:
        return 'Rabu';
        break;
      case 4:
        return 'Kamis';
        break;
      case 5:
        return 'Jumat';
        break;
      case 6:
        return 'Sabtu';
        break;
      case 7:
        return 'Minggu';
        break;
      default:
        return 'Senin';
        break;
    }
  }

  static int getDaysN(String day) {
    switch (day) {
      case 'Sen':
        return 2;
        break;
      case 'Sel':
        return 3;
        break;
      case 'Rab':
        return 4;
        break;
      case 'Kam':
        return 5;
        break;
      case 'Jum':
        return 6;
        break;
      case 'Sab':
        return 7;
        break;
      case 'Min':
        return 1;
        break;
      default:
        return 1;
        break;
    }
  }

  static String getDayAbrevation3Letters(number) {
    String labelDate = "";
    switch (number) {
      case 1:
        labelDate = "Sen";
        break;
      case 2:
        labelDate = "Sel";
        break;
      case 3:
        labelDate = "Rab";
        break;
      case 4:
        labelDate = "Kam";
        break;
      case 5:
        labelDate = "Jum";
        break;
      case 6:
        labelDate = "Sab";
        break;
      case 7:
        labelDate = "Min";
        break;
    }
    return labelDate;
  }

  static bool dayPass(String fechax, String fechaActual) {
    bool re = false;
    if (fechax == fechaActual) {
      re = true;
    }
    return re;
  }

  static String getHora(TimeOfDay hora) {
    return '${needZero(hora.hour)}:${needZero(hora.minute)}:00';
  }

  static String getTime(DateTime x) {
    return '${needZero(x.hour)}:${needZero(x.minute)}';
  }

  static String getTimeOfDayS(TimeOfDay x) {
    return '${needZero(x.hour)}:${needZero(x.minute)}';
  }

  static String getDateAbrevation(number) {
    String labelDate = "";
    switch (number) {
      case 1:
        labelDate = "Januari";
        break;
      case 2:
        labelDate = "Februari";
        break;
      case 3:
        labelDate = "Maret";
        break;
      case 4:
        labelDate = "Abril";
        break;
      case 5:
        labelDate = "Mei";
        break;
      case 6:
        labelDate = "Juni";
        break;
      case 7:
        labelDate = "Juli";
        break;
      case 8:
        labelDate = "Agustus";
        break;
      case 9:
        labelDate = "September";
        break;
      case 10:
        labelDate = "Oktober";
        break;
      case 11:
        labelDate = "November";
        break;
      case 12:
        labelDate = "Desember";
        break;
    }
    return labelDate;
  }

  static String getDaysStr(int day) {
    switch (day) {
      case 2:
        return 'Sen';
        break;
      case 3:
        return 'Sel';
        break;
      case 4:
        return 'Rab';
        break;
      case 5:
        return 'Kam';
        break;
      case 6:
        return 'Jum';
        break;
      case 7:
        return 'Sab';
        break;
      case 1:
        return 'Min';
        break;
      default:
        return 'Min';
        break;
    }
  }

  static bool timePass(DateTime now, DateTime x) {
    bool re = false;
    DateTime no2 =
        DateTime(now.year, now.month, now.day, now.hour, now.minute, 0);
    print('different ${x.difference(no2).inMinutes}');
    if (x.difference(no2).inMinutes >= 0) {
      re = true;
    }
    return re;
  }

  static String passslashtoguide(String fecha) {
    DateTime d = DateFormat('dd/MM/yyyy').parse(fecha);
    return DateFormat('yyyy-MM-dd').format(d);
  }
}
