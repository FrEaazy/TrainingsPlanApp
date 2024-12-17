import SwiftUI

struct ContentView: View {
    @State private var trainingPlans: [TrainingPlan] = []
    @State private var showNewPlanView = false

    var body: some View {
        NavigationView {
            VStack {
                if trainingPlans.isEmpty {
                    Text("Keine Trainingspläne vorhanden. Erstelle einen neuen Plan.")
                        .padding()
                } else {
                    List {
                        ForEach(trainingPlans) { plan in
                            NavigationLink(destination: TrainingPlanView(trainingPlan: $trainingPlans[getIndex(of: plan)])) {
                                Text(plan.name)
                            }
                        }
                        .onDelete(perform: deletePlan)
                    }
                }
                Button(action: { showNewPlanView = true }) {
                    Text("Neuen Trainingsplan erstellen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Trainingspläne")
            .sheet(isPresented: $showNewPlanView) {
                NewPlanView { newPlan in
                    trainingPlans.append(newPlan)
                }
            }
        }
    }

    func deletePlan(at offsets: IndexSet) {
        trainingPlans.remove(atOffsets: offsets)
    }

    func getIndex(of plan: TrainingPlan) -> Int {
        trainingPlans.firstIndex(where: { $0.id == plan.id }) ?? 0
    }
}

struct TrainingPlanView: View {
    @Binding var trainingPlan: TrainingPlan
    @State private var showNewExerciseView = false

    var body: some View {
        VStack {
            List {
                ForEach(trainingPlan.exercises) { exercise in
                    NavigationLink(destination: ExerciseTrackerView(exercise: $trainingPlan.exercises[getIndex(of: exercise)])) {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text("Sätze: \(exercise.plannedSets), Wiederholungen: \(exercise.plannedReps), Gewicht: \(String(format: "%.2f", exercise.plannedWeight)) kg")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle(trainingPlan.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showNewExerciseView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewExerciseView) {
                NewExerciseView { newExercise in
                    trainingPlan.exercises.append(newExercise)
                }
            }
        }
    }

    func getIndex(of exercise: Exercise) -> Int {
        trainingPlan.exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
    }
}

struct ExerciseTrackerView: View {
    @Binding var exercise: Exercise
    @State private var showNewEntryView = false

    var body: some View {
        VStack {
            List {
                ForEach(exercise.entries) { entry in
                    HStack {
                        Text("Satz: \(entry.set) - Gewicht: \(String(format: "%.2f", entry.weight)) kg - Wiederholungen: \(entry.reps)")
                        Spacer()
                        Text(entry.date, style: .date)
                    }
                }
            }
            .navigationTitle(exercise.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showNewEntryView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewEntryView) {
                NewEntryView { newEntry in
                    exercise.entries.append(newEntry)
                }
            }
        }
    }
}

struct NewPlanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var planName = ""
    var onSave: (TrainingPlan) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Plan Name", text: $planName)
            }
            .navigationTitle("Neuen Plan erstellen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let newPlan = TrainingPlan(name: planName, exercises: [])
                        onSave(newPlan)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NewExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exerciseName = ""
    @State private var plannedSets = ""
    @State private var plannedReps = ""
    @State private var plannedWeight = ""
    var onSave: (Exercise) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Übungsname", text: $exerciseName)
                TextField("Sätze", text: $plannedSets)
                    .keyboardType(.numberPad)
                TextField("Wiederholungen", text: $plannedReps)
                    .keyboardType(.numberPad)
                TextField("Gewicht (kg)", text: $plannedWeight)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Neue Übung hinzufügen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if let sets = Int(plannedSets), let reps = Int(plannedReps), let weight = Double(plannedWeight) {
                            let newExercise = Exercise(name: exerciseName, plannedSets: sets, plannedReps: reps, plannedWeight: weight, entries: [])
                            onSave(newExercise)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NewEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var setNumber = ""
    @State private var weight = ""
    @State private var reps = ""
    var onSave: (Entry) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Satz", text: $setNumber)
                    .keyboardType(.numberPad)
                TextField("Gewicht (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Wiederholungen", text: $reps)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Neuen Eintrag hinzufügen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if let setValue = Int(setNumber), let weightValue = Double(weight), let repsValue = Int(reps) {
                            let newEntry = Entry(set: setValue, weight: weightValue, reps: repsValue, date: Date())
                            onSave(newEntry)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Models
struct TrainingPlan: Identifiable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var plannedSets: Int
    var plannedReps: Int
    var plannedWeight: Double
    var entries: [Entry]
}

struct Entry: Identifiable {
    let id = UUID()
    var set: Int
    var weight: Double
    var reps: Int
    var date: Date
}

@main
struct TrainingPlanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
