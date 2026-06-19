package cz.mendelu.gtagarage.navigation

interface INavigationRouter {
    fun navigateToOwnedGarageList()
    fun navigateToGarageList()
    fun navigateToGarageDetail(garageId: String)
    fun navigateToCarsInGarage(garageId: String)
    fun navigateToMap()
    fun navigateToStatistics()
    fun returnBack()
    fun navigateToAddEditCar(garageId: String, carId: String? = null)
    fun navigateToCarDetail(carId: String)
}