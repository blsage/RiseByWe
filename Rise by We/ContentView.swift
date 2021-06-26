//
//  ContentView.swift
//  Rise by We
//
//  Created by Benjamin Leonardo Sage on 6/23/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var liftModel: ExerciseModel
    @State var showDataPopup = false
    
    var date: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            TabView {
                VStack {
                    LiftCard(exercise: $liftModel.exercises[0])
                    LiftCard(exercise: $liftModel.exercises[1])
                }
                VStack {
                    LiftCard(exercise: $liftModel.exercises[2])
                    LiftCard(exercise: $liftModel.exercises[3])
                }
                VStack {
                    LiftCard(exercise: $liftModel.exercises[4])
                    LiftCard(exercise: $liftModel.exercises[5])
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .sheet(isPresented: $showDataPopup) {
                RecapView()
            }
            .navigationTitle(date)
            .navigationBarItems(trailing: Button {
                showDataPopup = true
            } label: {
                Image(systemName: "info.circle")
            })
        }
    }
}

struct LiftCard: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        if !exercise.justUpdated {
            VStack {
                Text(exercise.name)
                    .font(.title.smallCaps())
                Text("\(exercise.levelString)")
                    .fontWeight(.bold)
                    .font(.system(size: 45, design: .rounded))
                HStack {
                    Button {
                        exercise.update(hit: true)
                    } label : {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                    Button {
                        exercise.update(hit: false)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        } else {
            VStack {
                HStack {
                    Text("\(exercise.name) completed.")

                    if exercise.hitLast {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                Button("Undo") { exercise.undo() }
            }
        }
    }
}

struct RecapView: View {
    @EnvironmentObject var model: ExerciseModel
    @State var text = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            TextEditor(text: $text)
                .padding()
                .navigationBarTitle("Progress")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .onAppear { text = model.recapText }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecapView()
            .environmentObject(ExerciseModel())
    }
}
