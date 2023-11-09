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
            VStack(spacing: 0) {
                ClockView()
                    .frame(width: 170, height: 170)
                    .padding()
                
                TabView {
                    VStack(spacing: 0) {
                        PlatesView(exercise: liftModel.exercises[0] as! WeightedExercise)
                        LiftCard(exercise: $liftModel.exercises[0])
                        PlatesView(exercise: liftModel.exercises[1] as! WeightedExercise)
                        LiftCard(exercise: $liftModel.exercises[1])
                    }
                    VStack(spacing: 0) {
                        PlatesView(exercise: liftModel.exercises[2] as! WeightedExercise)
                        LiftCard(exercise: $liftModel.exercises[2])
                        LiftCard(exercise: $liftModel.exercises[3])
                    }
                    VStack(spacing: 0) {
                        PlatesView(exercise: liftModel.exercises[4] as! WeightedExercise)
                        LiftCard(exercise: $liftModel.exercises[4])
                        PlatesView(exercise: liftModel.exercises[5] as! WeightedExercise)
                        LiftCard(exercise: $liftModel.exercises[5])
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .sheet(isPresented: $showDataPopup) {
                    RecapView()
                        .tint(.orange)
                }
                .navigationTitle(date)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showDataPopup = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
        }
    }
}

struct LiftCard: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        if !exercise.justUpdated {
            VStack {
                Text(exercise.name)
                    .font(.largeTitle.smallCaps())
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
            .padding([.horizontal, .bottom])
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

struct SupersetStack: View {
    @Binding var exercise1: Exercise
    @Binding var exercise2: Exercise
    
    var body: some View {
        VStack {
            LiftCard(exercise: $exercise1)
            LiftCard(exercise: $exercise2)
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

struct PlatesView: View {
    var exercise: WeightedExercise
    
    var platesText: String {
        let plates = WeightedExercise.calculatePlates(fromWeight: exercise.weight)
        return plates.map { String(format: "%g", $0) }.joined(separator: ", ")
    }
    
    var body: some View {
        Text(platesText)
            .foregroundColor(.secondary)
            .font(.callout)
            .padding(.top)
    }
}

struct SupersetView: View {
    var exercise1: WeightedExercise
    var exercise2: WeightedExercise
    
    var weightText: String {
        let (base, additionalWeight, firstLighter) = WeightedExercise.calculateSupersetPlates(fromWeight: exercise1.weight, and: exercise2.weight)
        
        let firstString = base.isEmpty ? "0" : base.map { String(format: "%g", $0) }.joined(separator: ", ")
        let secondString = additionalWeight.isEmpty ? "0" : additionalWeight.map { String(format: "%g", $0) }.joined(separator: ", ")
        
        if firstLighter {
            return firstString + ", then add " + secondString + "."
        } else {
            return firstString + ". Add " + secondString + ", then remove."
        }
    }
    
    var body: some View {
        Text(weightText)
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ExerciseModel())
    }
}
