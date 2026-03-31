import SwiftUI
import MapKit

struct MapPinPickerView: View {
    @Environment(\.dismiss) private var dismiss

    var onConfirm: (CLLocationCoordinate2D, String?, City?) -> Void

    @State private var position: MapCameraPosition = .automatic
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565)
    @State private var addressText: String?
    @State private var isGeocoding = false

    private let geocoder = CLGeocoder()

    var body: some View {
        NavigationStack {
            ZStack {
                // 地圖
                MapReader { proxy in
                    Map(position: $position)
                        .mapStyle(.standard)
                        .mapControls {
                            MapCompass()
                            MapUserLocationButton()
                        }
                        .onMapCameraChange(frequency: .onEnd) { context in
                            centerCoordinate = context.camera.centerCoordinate
                            reverseGeocode(centerCoordinate)
                        }
                }

                // 中央準心 pin
                VStack {
                    Image(systemName: "mappin")
                        .font(.system(size: 36))
                        .foregroundStyle(.appPrimary)
                    // pin 底部的陰影點
                    Circle()
                        .fill(.black.opacity(0.2))
                        .frame(width: 8, height: 4)
                }
                .offset(y: -18) // 讓 pin 尖端對準中心

                // 底部確認區
                VStack {
                    Spacer()

                    VStack(spacing: 12) {
                        if isGeocoding {
                            HStack(spacing: 6) {
                                ProgressView().controlSize(.small)
                                Text("取得地址中...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else if let address = addressText {
                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }

                        Button {
                            let city = matchCity(for: centerCoordinate)
                            onConfirm(centerCoordinate, addressText, city)
                            dismiss()
                        } label: {
                            Text("確認位置")
                                .frame(maxWidth: .infinity, minHeight: 22)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.appPrimary)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("選擇位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear {
                if let userLocation = LocationManager.shared.userLocation {
                    centerCoordinate = userLocation
                }
                position = .region(MKCoordinateRegion(
                    center: centerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isGeocoding = true
        geocoder.cancelGeocode()

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                let parts = [placemark.locality, placemark.thoroughfare, placemark.subThoroughfare]
                    .compactMap { $0 }
                addressText = parts.isEmpty ? nil : parts.joined(separator: "")
            } else {
                addressText = nil
            }
            isGeocoding = false
        }
    }

    private func matchCity(for coordinate: CLLocationCoordinate2D) -> City? {
        // 簡單用最近的城市中心匹配
        City.allCases.min(by: { a, b in
            let distA = abs(a.defaultLatitude - coordinate.latitude) + abs(a.defaultLongitude - coordinate.longitude)
            let distB = abs(b.defaultLatitude - coordinate.latitude) + abs(b.defaultLongitude - coordinate.longitude)
            return distA < distB
        })
    }
}
