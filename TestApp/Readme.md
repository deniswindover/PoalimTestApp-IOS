### Poalim TestApp created by Denis Windover ###

ARCHITECTURE:
The architecture of this project is MVVM. I work with MVVM + RXSwift about 3 years. The concept of this desigh pattern is pretty simple. We have 2 main components in our architecture, the're VIEW and VIEWMODEL. The connection between them is made with observables-binders. ViewController doesn't contain any data or business logic, the only function of VIEW is to send user interaction to VIEWMODEL and get back a results. The one more advantage of RxSwift that it's reactive this means all changes been updating in realtime.
All views in the project (cells too) have viewmodel that controls all procceses and refreshing ui.

PROJECT:

RequestManager - Singleton class for making api requests
Navigator - Singleton class for navigation between pages
ImageCache - Singleton class for saving, removing and checking expiration images
Extension - Some useful extensions I've used

The rest looks clear and readable by names like models, views, cells.

PODS:

'Alamofire' - API Request Manager

'RxSwift'
'RxCocoa'

'ObjectMapper' - Mapping JSON to objects
'SDWebImage' - Images from net
'DWExt' - my pod with useful extensions
