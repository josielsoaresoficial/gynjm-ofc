import { useState } from "react";
import { MuscleGroup } from "@/pages/Exercises";
import bodyFront from "@/assets/body-front.png";
import bodyBack from "@/assets/body-back.png";
import { Button } from "@/components/ui/button";
import { Settings, Plus, Trash2, Save } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";

interface MuscleMapProps {
  view: "front" | "back";
  selectedMuscle: MuscleGroup | null;
  onMuscleSelect: (muscle: MuscleGroup) => void;
}

interface MuscleLabel {
  name: string;
  muscle: MuscleGroup;
  side: "left" | "right";
  top: string;
  fontSize?: number;
  lineLength?: number;
  lineShape?: "straight" | "curved";
  dotPosition?: "start" | "end";
  hideLabel?: boolean;
}

const defaultFrontLabels: MuscleLabel[] = [
  { name: "Ombros", muscle: "ombros", side: "left", top: "18%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Bíceps", muscle: "biceps", side: "left", top: "32%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Oblíquos", muscle: "obliquos", side: "left", top: "46%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Abdutores", muscle: "abdutores", side: "left", top: "60%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Quadríceps", muscle: "quadriceps", side: "left", top: "74%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Peitoral", muscle: "peitoral", side: "right", top: "22%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Abdômen", muscle: "abdomen", side: "right", top: "38%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Antebraços", muscle: "antebracos", side: "right", top: "52%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Adutores", muscle: "adutores", side: "right", top: "66%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Cardio", muscle: "cardio", side: "right", top: "80%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
];

const defaultBackLabels: MuscleLabel[] = [
  { name: "Trapézio", muscle: "trapezio", side: "right", top: "16%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Tríceps", muscle: "triceps", side: "left", top: "30%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Dorsais", muscle: "dorsais", side: "right", top: "32%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Lombares", muscle: "lombares", side: "left", top: "46%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Glúteos", muscle: "gluteos", side: "right", top: "52%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Isquiotibiais", muscle: "isquiotibiais", side: "left", top: "66%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Cardio", muscle: "cardio", side: "right", top: "70%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
  { name: "Panturrilhas", muscle: "panturrilhas", side: "left", top: "84%", fontSize: 14, lineLength: 40, lineShape: "straight", dotPosition: "end", hideLabel: false },
];

export function MuscleMap({ view, selectedMuscle, onMuscleSelect }: MuscleMapProps) {
  const [editMode, setEditMode] = useState(false);
  const [frontLabels, setFrontLabels] = useState<MuscleLabel[]>(defaultFrontLabels);
  const [backLabels, setBackLabels] = useState<MuscleLabel[]>(defaultBackLabels);
  const [editingLabel, setEditingLabel] = useState<MuscleLabel | null>(null);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);

  const labels = view === "front" ? frontLabels : backLabels;
  const setLabels = view === "front" ? setFrontLabels : setBackLabels;

  const handleEditLabel = (label: MuscleLabel) => {
    if (editMode) {
      setEditingLabel(label);
      setIsEditDialogOpen(true);
    } else {
      onMuscleSelect(label.muscle);
    }
  };

  const handleSaveEdit = () => {
    if (editingLabel) {
      const updatedLabels = labels.map(l => 
        l.muscle === editingLabel.muscle ? editingLabel : l
      );
      setLabels(updatedLabels);
      setIsEditDialogOpen(false);
      setEditingLabel(null);
    }
  };

  const handleAddLabel = () => {
    const newLabel: MuscleLabel = {
      name: "Novo Músculo",
      muscle: "cardio",
      side: "left",
      top: "50%",
      fontSize: 14,
      lineLength: 40,
      lineShape: "straight",
      dotPosition: "end",
      hideLabel: false,
    };
    setLabels([...labels, newLabel]);
  };

  const handleRemoveLabel = (muscle: MuscleGroup) => {
    setLabels(labels.filter(l => l.muscle !== muscle));
    setIsEditDialogOpen(false);
    setEditingLabel(null);
  };

  const renderLine = (label: MuscleLabel, isSelected: boolean, isHovered: boolean) => {
    const lineColor = isSelected ? "#FF9F66" : isHovered ? "#FF9F66" : "#9CA3AF";
    const lineLength = label.lineLength || 40;
    
    if (label.lineShape === "curved") {
      const path = label.side === "left" 
        ? `M 0 0 Q ${lineLength/2} -10, ${lineLength} 0`
        : `M 0 0 Q ${lineLength/2} 10, ${lineLength} 0`;
      
      return (
        <svg width={lineLength} height="20" className="overflow-visible">
          <path d={path} fill="none" stroke={lineColor} strokeWidth="1" />
          {label.dotPosition === "end" && (
            <circle cx={lineLength} cy="0" r="4" fill={lineColor} />
          )}
          {label.dotPosition === "start" && (
            <circle cx="0" cy="0" r="4" fill={lineColor} />
          )}
        </svg>
      );
    }
    
    return (
      <div className="relative flex items-center">
        {label.dotPosition === "start" && (
          <div
            className="w-2 h-2 transition-colors duration-200"
            style={{ backgroundColor: lineColor }}
          />
        )}
        <div
          className="h-[1px] transition-colors duration-200"
          style={{ width: `${lineLength}px`, backgroundColor: lineColor }}
        />
        {label.dotPosition === "end" && (
          <div
            className="w-2 h-2 transition-colors duration-200"
            style={{ backgroundColor: lineColor }}
          />
        )}
      </div>
    );
  };

  return (
    <div className="relative w-full flex flex-col items-center justify-center py-8">
      {/* Edit Mode Toggle */}
      <div className="absolute top-2 right-2 z-20">
        <Button
          onClick={() => setEditMode(!editMode)}
          variant={editMode ? "default" : "outline"}
          size="sm"
          className="gap-2"
        >
          <Settings className="w-4 h-4" />
          {editMode ? "Sair" : "Editar"}
        </Button>
      </div>

      {editMode && (
        <div className="absolute top-2 left-2 z-20">
          <Button
            onClick={handleAddLabel}
            variant="outline"
            size="sm"
            className="gap-2"
          >
            <Plus className="w-4 h-4" />
            Adicionar
          </Button>
        </div>
      )}

      {/* Container with fixed max-width for consistent sizing */}
      <div className="relative w-full max-w-[600px] flex items-center justify-center">
        {/* Body Image - Centered */}
        <div className="relative flex items-center justify-center transition-all duration-300 ease-in-out">
          <img
            src={view === "front" ? bodyFront : bodyBack}
            alt={view === "front" ? "Vista frontal do corpo" : "Vista traseira do corpo"}
            className="w-[280px] h-auto object-contain transition-opacity duration-300"
            style={{ maxHeight: "600px" }}
          />
        </div>

        {/* Muscle Labels - Positioned absolutely */}
        <div className="absolute inset-0 pointer-events-none">
          {labels.map((label) => {
            const isSelected = selectedMuscle === label.muscle;
            
            return (
              <div
                key={label.muscle}
                className={`absolute pointer-events-auto ${
                  label.side === "left" ? "left-0" : "right-0"
                } cursor-pointer group`}
                style={{ top: label.top }}
                onClick={() => handleEditLabel(label)}
              >
                {/* Label Container */}
                <div className={`flex items-center ${label.side === "left" ? "flex-row" : "flex-row-reverse"} gap-1`}>
                  {/* Label Text */}
                  {!label.hideLabel && (
                    <div
                      className={`font-medium text-black px-2 py-1 whitespace-nowrap ${
                        label.side === "left" ? "text-left" : "text-right"
                      } ${
                        isSelected
                          ? "font-bold text-[#FF9F66]"
                          : "group-hover:font-semibold group-hover:text-[#FF9F66]"
                      } transition-all duration-200`}
                      style={{ fontSize: `${label.fontSize || 14}px` }}
                    >
                      {label.name}
                    </div>
                  )}

                  {/* Connector Line and Point */}
                  {renderLine(label, isSelected, false)}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Edit Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Editar Label</DialogTitle>
          </DialogHeader>
          {editingLabel && (
            <div className="space-y-4">
              <div>
                <Label>Nome</Label>
                <Input
                  value={editingLabel.name}
                  onChange={(e) => setEditingLabel({ ...editingLabel, name: e.target.value })}
                />
              </div>

              <div>
                <Label>Tamanho do Texto (px)</Label>
                <Input
                  type="number"
                  value={editingLabel.fontSize || 14}
                  onChange={(e) => setEditingLabel({ ...editingLabel, fontSize: parseInt(e.target.value) })}
                />
              </div>

              <div>
                <Label>Comprimento da Linha (px)</Label>
                <Input
                  type="number"
                  value={editingLabel.lineLength || 40}
                  onChange={(e) => setEditingLabel({ ...editingLabel, lineLength: parseInt(e.target.value) })}
                />
              </div>

              <div>
                <Label>Forma da Linha</Label>
                <Select
                  value={editingLabel.lineShape || "straight"}
                  onValueChange={(value: "straight" | "curved") => setEditingLabel({ ...editingLabel, lineShape: value })}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="straight">Reta</SelectItem>
                    <SelectItem value="curved">Curva</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label>Posição do Ponto</Label>
                <Select
                  value={editingLabel.dotPosition || "end"}
                  onValueChange={(value: "start" | "end") => setEditingLabel({ ...editingLabel, dotPosition: value })}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="start">Início</SelectItem>
                    <SelectItem value="end">Fim</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label>Lado</Label>
                <Select
                  value={editingLabel.side}
                  onValueChange={(value: "left" | "right") => setEditingLabel({ ...editingLabel, side: value })}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="left">Esquerda</SelectItem>
                    <SelectItem value="right">Direita</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label>Posição Vertical (%)</Label>
                <Input
                  value={editingLabel.top}
                  onChange={(e) => setEditingLabel({ ...editingLabel, top: e.target.value })}
                  placeholder="Ex: 50%"
                />
              </div>

              <div className="flex items-center space-x-2">
                <Switch
                  checked={editingLabel.hideLabel || false}
                  onCheckedChange={(checked) => setEditingLabel({ ...editingLabel, hideLabel: checked })}
                />
                <Label>Ocultar Texto (apenas linha)</Label>
              </div>

              <div className="flex gap-2 pt-4">
                <Button onClick={handleSaveEdit} className="flex-1">
                  <Save className="w-4 h-4 mr-2" />
                  Salvar
                </Button>
                <Button 
                  variant="destructive" 
                  onClick={() => handleRemoveLabel(editingLabel.muscle)}
                  className="flex-1"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  Remover
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
