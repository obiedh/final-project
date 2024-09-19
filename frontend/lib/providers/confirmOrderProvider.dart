import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/reservation.dart';

Reservation reservation = Reservation(
  imageURL: "",
  location: "",
  name: "",
  stadiumId: "",
  status: "pending",
  date: "",
  intervalTime: "",
  price: 30,
  reservationUuid: "",
  reservationId: "",
);

class ConfirmOrderNotifier extends StateNotifier<Reservation> {
  ConfirmOrderNotifier() : super(reservation);

  void makeReservation(Reservation reservation) {
    state = reservation;
  }

  void addTimeInterval(String time, String price) {
    state = Reservation(
      imageURL: state.imageURL,
      location: state.location,
      name: state.name,
      status: state.status,
      date: state.date,
      stadiumId: state.stadiumId,
      intervalTime: time,
      reservationUuid: state.reservationUuid,
      price: double.parse(price),
      reservationId: state.reservationId,
    );
  }

  void addDate(String date) {
    state = Reservation(
      imageURL: state.imageURL,
      location: state.location,
      name: state.name,
      status: state.status,
      date: date,
      stadiumId: state.stadiumId,
      intervalTime: state.intervalTime,
      reservationUuid: state.reservationUuid,
      price: state.price,
      reservationId: state.reservationId,
    );
  }
}

final confirmOrderProvider =
    StateNotifierProvider<ConfirmOrderNotifier, Reservation>((ref) {
  return ConfirmOrderNotifier();
});
