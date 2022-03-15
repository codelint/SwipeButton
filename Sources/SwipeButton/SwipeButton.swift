//
//  SwipeButton.swift
//  trac
//
//  Created by gzhang on 2021/6/7.
//


import SwiftUI

@available(iOS 14.0, OSX 10.15, *)
public struct ButtonOption {
    var text: String
    var backgroundColor: Color = .red
    var foregroundColor: Color = .white
    var isTip: Bool = true
    var action: ((@escaping () -> Void) -> Void)? = nil
}

@available(iOS 14.0, OSX 10.15, *)
public enum ButtonDefine{
    case custom(String, Color, Color, (@escaping () -> Void) -> Void)
    case quick(String, Color, (@escaping () -> Void) -> Void)
    case simple(String, Color)
    case common(String, Color, (@escaping () -> Void) -> Void)
}


@available(iOS 14.0, OSX 10.15, *)
public struct SwipeButton<Content:View>: View {
    
    @GestureState private var translation: CGSize = .zero
    @State var buttonWidth: CGFloat = .zero
    @State var widths: [String:CGFloat] = [String:CGFloat]()
    @State var isDragging = false
    @State var scrollX: CGFloat = .zero
    @State var contentHeight: CGFloat = .zero
    @State var selected: Int? = nil
    
    var maxWidth: CGFloat = 0.0
    
    var options: [ButtonOption] = []
    
    @ViewBuilder
    public var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public init(maxWidth: CGFloat, defines: [ButtonDefine], @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.maxWidth = maxWidth
        for define in defines {
            switch define {
            case .common(let text, let bgColor, let action):
                if text.count > 0 {
                    options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: .white, action: action))
                }
            case .quick(let text, let bgColor, let action):
                if text.count > 0 {
                    options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: .white, isTip: false, action: action))
                }
            case .custom(let text, let bgColor, let color, let action):
                options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: color, action: action))
            case .simple(let text, let bgColor):
                options.append(ButtonOption(text: text, backgroundColor: bgColor))
            }
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { event in
                withAnimation {
                    self.isDragging = true
                    if(event.translation.width > 0){
                        self.scrollX = 0
                    }else{
                        self.scrollX = event.translation.width + buttonWidth > 0 ? (abs(event.translation.width) > 16 ? event.translation.width: 0) : (0-buttonWidth)
                    }
                }
                
            }
            .onEnded { event in
                print("ended...")
                let x = (event.translation.width + buttonWidth/2) > 0 ?  0 : (0-buttonWidth)
                // x = self.scrollX < -32 && self.scrollX > 32 ? self.scrollX : 0
                withAnimation(.linear(duration: 0.2)) {
                    self.isDragging = false
                    self.scrollX = x
                }
                
                if self.scrollX < 5 {
                    select(offset: nil)
                }
            }.updating($translation) { value, state, _ in
                state = value.translation
            }
    }
    
    func fold() {
        withAnimation {
            scrollX = 0
            selected = nil
        }
    }
    
    func unfold() {
        withAnimation {
            self.scrollX = 0 - buttonWidth
        }
    }
    
    func buttonWidth(offset: Int) -> CGFloat {
        if let selected = self.selected {
            if selected < offset {
                return widths[options[offset].text] ?? 0
            }
            if selected > offset {
                return 0
            }
            
            return buttonWidth
        }else{
            return widths[options[offset].text] ?? 0
        }
    }
    
    func buttonOffset(offset: Int) -> CGFloat {
        
        let pre:CGFloat = (options.enumerated()).reduce(0.0, { res, item in
            if item.offset < offset {
                return res + (widths[item.element.text] ?? 0)
            }
            return res
        })
        
        if let selected = self.selected {
            if selected < offset {
                return self.maxWidth + buttonWidth
            }
            if selected > offset {
                return self.maxWidth + pre - pre*(scrollX + buttonWidth)/buttonWidth
            }

            return self.maxWidth
        }else{
            return self.maxWidth + pre - pre*(scrollX + buttonWidth)/buttonWidth
        }
        
        
    }
    
    func select(offset: Int?) {
        withAnimation {
            selected = offset
        }
    }
    
    public var body: some View {
        VStack {
//            Text(translation.width.description)
            ZStack(alignment: .leading){
                HStack(spacing:0){
                  
                    content()
                        .background(GeometryReader{ proxy in
                            Color.clear.preference(key: ObservableSwipeButtonHeightPreferenceKey.self, value: [proxy.size.height])
                        })
                        .onPreferenceChange(ObservableSwipeButtonHeightPreferenceKey.self) { value in
                            if value.count > 0 {
                                contentHeight = value.reduce(0, { res, next in
                                    return res < next ? next : res
                                    // return res + next
                                })
                            }
                        }
                }
                .frame(width: self.maxWidth)
                
                if buttonWidth > 0 {
                    HStack{
                        Spacer()
                    }
                    .frame(width: self.maxWidth, height: contentHeight)
                    .background(Color.gray)
                    .opacity(0.3)
                    .offset(x: self.maxWidth*(scrollX + buttonWidth)/buttonWidth)
                    .onTapGesture {
                        if selected == nil {
                            fold()
                        }else{
                            select(offset: nil)
                        }
                        
                    }
                }
                
                ForEach(Array(self.options.enumerated()), id: \.offset) { e in
                    Button(action: {
                        if self.selected == nil && options[e.offset].isTip {
                            select(offset: e.offset)
                            return
                        }
                        
                        if let f = options[e.offset].action {
                            f({
                                fold()
                            })
                        }else{
                            fold()
                        }
                    }, label: {
                        // ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        Text(options[e.offset].text)
                            .padding()
                            .foregroundColor(options[e.offset].foregroundColor)
                            .frame(width: buttonWidth(offset: e.offset), height: contentHeight)
                            .background(options[e.offset].backgroundColor)
                            
                            
                    })
                    .offset(x: buttonOffset(offset: e.offset))
                }
                
                ForEach(Array(self.options.enumerated()), id: \.offset) { e in
                    Button(action: {
                        
                    }, label: {
                        // ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        Text(options[e.offset].text)
                            .padding()
                            .foregroundColor(options[e.offset].foregroundColor)
                            .frame(height: contentHeight)
                            .background(options[e.offset].backgroundColor)
                            
                    })
                    .offset(x: self.maxWidth + buttonWidth)
                    .background(GeometryReader{ proxy in
                        Color.clear.preference(key: ObservableSwipeButtonWidthPreferenceKey.self, value: [options[e.offset].text: proxy.size.width])
                    })
                }
                    
                
            }
            .offset(x: scrollX, y: 0)
            .highPriorityGesture(drag)
            .onPreferenceChange(ObservableSwipeButtonWidthPreferenceKey.self) { value in
                buttonWidth = value.values.reduce(0, { res, v in
                    return res + v
                })
                widths = value
            }
            
        }
        .frame(width: self.maxWidth)
        .clipped()
    }

}

struct ObservableSwipeButtonHeightPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    static var defaultValue:[CGFloat] = []

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        // value = nextValue()
        // value = nextValue()
        value.append(contentsOf: nextValue())
    }
}

struct ObservableSwipeButtonWidthPreferenceKey: PreferenceKey {
    typealias Value = [String:CGFloat]
    static var defaultValue:[String:CGFloat] = [String:CGFloat]()

    static func reduce(value: inout [String:CGFloat], nextValue: () -> [String:CGFloat]) {
        // value = nextValue()
        // value.append(contentsOf: nextValue())
        for (k, v) in nextValue() {
            value[k] = v
        }
    }
}

