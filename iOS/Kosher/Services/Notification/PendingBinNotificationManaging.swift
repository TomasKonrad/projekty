// sprava geofence regionu a lokalnych notifikaci pro cekajici biny
protocol PendingBinNotificationManaging {
    func requestPermission()
    func updateMonitoredBins(_ bins: [RecyclingLocation])
}
