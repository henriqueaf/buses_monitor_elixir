import { distanceInKm } from "@/js/utils/geo";

export const RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

export const MAX_DISTANCE_FROM_CENTER_KM = 100;

export const filterBusesWithEngineOn = (buses) => {
  return buses.filter(bus => bus.ignicao === 1);
}

export const filterBusesWithinRadius = (buses) => {
  return buses.filter(
    bus => distanceInKm(RIO_DE_JANEIRO_COORDINATES, [bus.latitude, bus.longitude]) <= MAX_DISTANCE_FROM_CENTER_KM
  );
}

export const filterVisibleBuses = (buses) => {
  return filterBusesWithinRadius(filterBusesWithEngineOn(buses));
}
