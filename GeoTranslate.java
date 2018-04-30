Import java.util.Date;
import java.util.List;

public class GeoTranslate {

	public static Coordinate move(double latitude, double longitude, double north, double east) {
		double rlatitude = deg2rad(latitude);
		double mPerDegLat = 111132.92 + (-559.82 * Math.cos(2 * rlatitude)) + (1.175*Math.cos(4 * rlatitude));		
		double mPerDegLng = (111412.84 * Math.cos(rlatitude)) + (-93.5 * Math.cos(3 * rlatitude));
		
		Coordinate c = new Coordinate();
		c.latitude = latitude + (north / mPerDegLat);
		c.longitude = longitude + (east / mPerDegLng);
		
		return c;
	}
	
	public static double distance(double latitude1, double longitude1, double latitude2, double longitude2) {
		double theta = longitude1 - longitude2;
		double dist = Math.sin(deg2rad(latitude1)) * Math.sin(deg2rad(latitude2)) + Math.cos(deg2rad(latitude1)) * Math.cos(deg2rad(latitude2)) * Math.cos(deg2rad(theta));
		dist = Math.acos(dist);
		dist = rad2deg(dist);
		dist = dist * 60 * 1.1515 * 1.609344 * 1000;
		return dist;
	}
	
	public static double deg2rad(double deg) {
		return (deg * Math.PI / 180.0);
	}

	public static double rad2deg(double rad) {
		return (rad * 180.0 / Math.PI);
	}
	
	public static double distanceScore(double latitude1, double longitude1, double latitude2, double longitude2, double radius) {
		return Math.max(0, 1 - (distance(latitude1, longitude1, latitude2, longitude2) / radius));
	}

	public static double bestDistanceScore(List<Search> searches, double latitude, double longitude) {
		double distanceScore = 0.0;
		for (Search search : searches) {
			if (search.isActive() && !search.isNegative()) {
				distanceScore = Math.max(distanceScore, distanceScore(search.getLatitude(), search.getLongitude(), latitude, longitude, search.getRadius()));
			}
		}
		return distanceScore;
	}

	public static long timeSince(Date date) {
		return ((new Date()).getTime() - date.getTime()) / 1000;
	}

	public static double timeScore(Date date) {
		return Math.max(0, 1.0 - (timeSince(date) / (60.0 * 60.0 * 6.0)));
	}
	
	public static double radiusScore(double radius) {
		return Math.max(0, 1 - (radius / 5000));
	}
}
