# SwipeButton

### How to

```swift
import SwiftUI
import SwipeButton

struct SwipeButtonTestView: View {
    
    @State var title: String = "Hello world!!!"

    var body: some View {
        NavigationView{
            VStack{
                Text(title)
                    .font(.title)
                    .bold()
                    .padding()
                SwipeButton(maxWidth: UIScreen.main.bounds.width, defines: [
                    .common("Delete", .red, { next in
                        title = "Delete!!!"
                        next()
                    }),
                    .quick("OK", .yellow, { next in
                        title = "OK!!!"
                        next()
                    }),
                    .simple("info", .blue),
                    .custom("cus", .gray, .black, { next in
                        title = "custom"
                        next()
                    })
                ], content: {
                    HStack{
                        Spacer()
                        Text("Please swipe me ^_^").padding()
                        Spacer()
                    }.background(.white)
                }).border(Color.gray)
                Spacer()
            }.background(.white)
            
        }
    }
}
```

