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
### Preview
![Image](https://github.com/codelint/SwipeButton/blob/4add02d90cd59339681669edf6f2dc1084e2c8de/Images/demo.gif)

