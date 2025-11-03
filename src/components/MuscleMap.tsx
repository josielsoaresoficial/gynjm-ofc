import { useState, useRef, useEffect } from "react";
import { MuscleGroup } from "@/pages/Exercises";
import bodyFront from "@/assets/body-front.png";
import bodyBack from "@/assets/body-back.png";
import { Button } from "@/components/ui/button";
import { Settings, Plus, Trash2, X } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Card } from "@/components/ui/card";

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
  const editPanelRef = useRef<HTMLDivElement>(null);

  const labels = view === "front" ? frontLabels : backLabels;
  const setLabels = view === "front" ? setFrontLabels : setBackLabels;

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (editPanelRef.current && !editPanelRef.current.contains(event.target as Node)) {
        const target = event.target as HTMLElement;
        if (!target.closest('[data-muscle-label]')) {
          setEditingLabel(null);
        }
      }
    };

    if (editingLabel && editMode) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => document.removeEventListener('mousedown', handleClickOutside);
    }
  }, [editingLabel, editMode]);

  const handleEditLabel = (label: MuscleLabel) => {
    if (editMode) {
      setEditingLabel(editingLabel?.muscle === label.muscle ? null : label);
    } else {
      onMuscleSelect(label.muscle);
    }
  };

  const handleUpdateLabel = (updates: Partial<MuscleLabel>) => {
    if (editingLabel) {
      const updatedLabel = { ...editingLabel, ...updates };
      setEditingLabel(updatedLabel);
      const updatedLabels = labels.map(l => 
        l.muscle === editingLabel.muscle ? updatedLabel : l
      );
      setLabels(updatedLabels);
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
    setEditingLabel(newLabel);
  };

  const handleRemoveLabel = () => {
    if (editingLabel) {
      setLabels(labels.filter(l => l.muscle !== editingLabel.muscle));
      setEditingLabel(null);
    }
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
            const isEditing = editingLabel?.muscle === label.muscle;
            
            return (
              <div
                key={label.muscle}
                className={`absolute pointer-events-auto ${
                  label.side === "left" ? "left-0" : "right-0"
                } cursor-pointer group`}
                style={{ top: label.top }}
                data-muscle-label
              >
                {/* Label Container */}
                <div className={`flex items-center ${label.side === "left" ? "flex-row" : "flex-row-reverse"} gap-1 relative`}>
                  {/* Label Text */}
                  <div onClick={() => handleEditLabel(label)}>
                    {!label.hideLabel && (
                      <div
                        className={`font-medium text-black px-2 py-1 whitespace-nowrap ${
                          label.side === "left" ? "text-left" : "text-right"
                        } ${
                          isSelected
                            ? "font-bold text-[#FF9F66]"
                            : "group-hover:font-semibold group-hover:text-[#FF9F66]"
                        } ${isEditing ? "ring-2 ring-primary rounded" : ""} transition-all duration-200`}
                        style={{ fontSize: `${label.fontSize || 14}px` }}
                      >
                        {label.name}
                      </div>
                    )}

                    {/* Connector Line and Point */}
                    {renderLine(label, isSelected, false)}
                  </div>

                  {/* Inline Edit Panel */}
                  {isEditing && editMode && (
                    <div 
                      ref={editPanelRef}
                      className={`absolute ${
                        label.side === "left" ? "left-full ml-2" : "right-full mr-2"
                      } top-0 z-50 pointer-events-auto`}
                    >
                      <Card className="p-3 shadow-lg bg-background border-2 border-primary w-64 max-h-[400px] overflow-y-auto">
                        <div className="space-y-3">
                          <div className="flex items-center justify-between mb-2">
                            <h4 className="font-semibold text-sm">Editar Label</h4>
                            <Button
                              variant="ghost"
                              size="sm"
                              className="h-6 w-6 p-0"
                              onClick={() => setEditingLabel(null)}
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </div>

                          <div className="space-y-2">
                            <Label className="text-xs">Nome</Label>
                            <Input
                              value={editingLabel.name}
                              onChange={(e) => handleUpdateLabel({ name: e.target.value })}
                              className="h-8 text-sm"
                            />
                          </div>

                          <div className="grid grid-cols-2 gap-2">
                            <div className="space-y-1">
                              <Label className="text-xs">Texto (px)</Label>
                              <Input
                                type="number"
                                value={editingLabel.fontSize || 14}
                                onChange={(e) => handleUpdateLabel({ fontSize: parseInt(e.target.value) })}
                                className="h-8 text-sm"
                              />
                            </div>

                            <div className="space-y-1">
                              <Label className="text-xs">Linha (px)</Label>
                              <Input
                                type="number"
                                value={editingLabel.lineLength || 40}
                                onChange={(e) => handleUpdateLabel({ lineLength: parseInt(e.target.value) })}
                                className="h-8 text-sm"
                              />
                            </div>
                          </div>

                          <div className="space-y-2">
                            <Label className="text-xs">Forma</Label>
                            <Select
                              value={editingLabel.lineShape || "straight"}
                              onValueChange={(value: "straight" | "curved") => handleUpdateLabel({ lineShape: value })}
                            >
                              <SelectTrigger className="h-8 text-sm">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="straight">Reta</SelectItem>
                                <SelectItem value="curved">Curva</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>

                          <div className="space-y-2">
                            <Label className="text-xs">Ponto</Label>
                            <Select
                              value={editingLabel.dotPosition || "end"}
                              onValueChange={(value: "start" | "end") => handleUpdateLabel({ dotPosition: value })}
                            >
                              <SelectTrigger className="h-8 text-sm">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="start">Início</SelectItem>
                                <SelectItem value="end">Fim</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>

                          <div className="space-y-2">
                            <Label className="text-xs">Lado</Label>
                            <Select
                              value={editingLabel.side}
                              onValueChange={(value: "left" | "right") => handleUpdateLabel({ side: value })}
                            >
                              <SelectTrigger className="h-8 text-sm">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="left">Esquerda</SelectItem>
                                <SelectItem value="right">Direita</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>

                          <div className="space-y-2">
                            <Label className="text-xs">Posição (%)</Label>
                            <Input
                              value={editingLabel.top}
                              onChange={(e) => handleUpdateLabel({ top: e.target.value })}
                              placeholder="Ex: 50%"
                              className="h-8 text-sm"
                            />
                          </div>

                          <div className="flex items-center space-x-2">
                            <Switch
                              checked={editingLabel.hideLabel || false}
                              onCheckedChange={(checked) => handleUpdateLabel({ hideLabel: checked })}
                            />
                            <Label className="text-xs">Ocultar texto</Label>
                          </div>

                          <Button 
                            variant="destructive" 
                            onClick={handleRemoveLabel}
                            className="w-full h-8 text-sm"
                            size="sm"
                          >
                            <Trash2 className="w-3 h-3 mr-1" />
                            Remover
                          </Button>
                        </div>
                      </Card>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
